// Tests for mot3r.mjs. node:test only, no dependencies, no network: every HTTP call goes to a fake fetch.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, writeFileSync, readFileSync, mkdirSync, existsSync, readdirSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { Readable, Writable } from 'node:stream';
import {
  VERSION,
  DEFAULT_URL,
  KEY_ENV,
  KEY_HIDDEN,
  HOSTS,
  resolveUrl,
  mergeJson,
  mergeVscode,
  redact,
  renderHost,
  install,
  parseSse,
  runShim,
  doctor,
  keyKind,
  parseArgs,
} from '../mot3r.mjs';

const KEY = 'mot_lk_live_' + 'a'.repeat(64);

function tempHome() {
  const home = mkdtempSync(join(tmpdir(), 'mot3r-test-'));
  return { home, env: { MOT_USER_HOME: home, APPDATA: join(home, 'AppData', 'Roaming'), XDG_CONFIG_HOME: join(home, '.config'), PATH: '' } };
}

function sink() {
  const chunks = [];
  const stream = new Writable({
    write(c, _e, cb) {
      chunks.push(String(c));
      cb();
    },
  });
  return { stream, lines: () => chunks.join('').split('\n').filter(Boolean) };
}

function fakeResponse(status, body, type = 'application/json', headers = {}) {
  const h = new Map(Object.entries({ 'content-type': type, ...headers }));
  return { status, headers: { get: (k) => h.get(k.toLowerCase()) ?? null }, text: async () => body };
}

test('version is 0.3.3 and the default endpoint is the mot MCP URL', () => {
  assert.equal(VERSION, '0.3.3');
  assert.equal(DEFAULT_URL, 'https://mcp.mot3r.com/mcp');
});

test('resolveUrl accepts https and loopback http, refuses plain http elsewhere', () => {
  assert.equal(resolveUrl(), DEFAULT_URL);
  assert.equal(resolveUrl('http://127.0.0.1:8787/mcp'), 'http://127.0.0.1:8787/mcp');
  assert.throws(() => resolveUrl('http://example.com/mcp'), /only over https/);
});

test('mergeJson keeps other servers and refuses broken files', () => {
  const before = JSON.stringify({ mcpServers: { other: { url: 'https://x' } }, theme: 'dark' });
  const after = JSON.parse(mergeJson(before, ['mcpServers', 'mot'], { url: DEFAULT_URL }));
  assert.deepEqual(after.mcpServers.other, { url: 'https://x' });
  assert.equal(after.mcpServers.mot.url, DEFAULT_URL);
  assert.equal(after.theme, 'dark');
  assert.throws(() => mergeJson('{ not json', ['a'], 1), /left untouched/);
  assert.throws(() => mergeJson('[]', ['a'], 1), /not a JSON object/);
});

test('mergeVscode adds the key input once, never twice', () => {
  const entry = HOSTS.vscode.entry(DEFAULT_URL);
  const once = mergeVscode('', 'mot', entry);
  const twice = JSON.parse(mergeVscode(once, 'mot', entry));
  assert.equal(twice.inputs.filter((i) => i.id === 'mot-key').length, 1);
  assert.equal(twice.servers.mot.headers.Authorization, 'Bearer ${input:mot-key}');
});

test('rendered configs reference the key, never contain one', () => {
  for (const id of Object.keys(HOSTS)) {
    const text = renderHost(id);
    assert.ok(text.includes(DEFAULT_URL) || id === 'claude-desktop', `${id} has the endpoint`);
    assert.ok(!/mot_[a-z]{2}_live_[0-9a-f]{8}/.test(text), `${id} carries no live key`);
  }
  assert.match(renderHost('claude-code'), /Authorization: Bearer \$\{MOT_KEY\}/);
  assert.match(renderHost('cursor'), /\$\{env:MOT_KEY\}/);
  assert.throws(() => renderHost('nope'), /unknown client/);
});

test('redact hides the key everywhere in a string', () => {
  assert.equal(redact(`a ${KEY} b ${KEY}`, KEY), `a ${KEY_HIDDEN} b ${KEY_HIDDEN}`);
  assert.equal(redact('nothing', ''), 'nothing');
});

test('install --dry-run writes nothing and never shows the key', () => {
  const { home, env } = tempHome();
  const rows = install({ hosts: ['cursor', 'vscode', 'claude-desktop', 'claude-code'], env: { ...env, [KEY_ENV]: KEY }, dryRun: true });
  assert.equal(rows.length, 4);
  for (const r of rows) {
    assert.equal(r.status, 'dry-run');
    assert.ok(!JSON.stringify(r).includes(KEY), `${r.host} report has no key`);
  }
  assert.ok(!existsSync(join(home, '.cursor')));
  assert.ok(!existsSync(join(home, '.mot')));
});

test('install writes Cursor and Claude Desktop, backs up the old file, keeps other servers', () => {
  const { home, env } = tempHome();
  mkdirSync(join(home, '.cursor'), { recursive: true });
  const cursorFile = join(home, '.cursor', 'mcp.json');
  writeFileSync(cursorFile, JSON.stringify({ mcpServers: { other: { url: 'https://x' } } }));
  const rows = install({ hosts: ['cursor', 'claude-desktop'], env: { ...env, [KEY_ENV]: KEY } });
  assert.ok(rows.every((r) => r.status === 'written'), JSON.stringify(rows));
  const cursor = JSON.parse(readFileSync(cursorFile, 'utf8'));
  assert.equal(cursor.mcpServers.mot.url, DEFAULT_URL);
  assert.ok(cursor.mcpServers.other);
  assert.equal(readdirSync(join(home, '.cursor')).filter((f) => f.includes('.mot-backup-')).length, 1);
  const desktop = rows.find((r) => r.host === 'claude-desktop');
  const cfg = JSON.parse(readFileSync(desktop.file, 'utf8'));
  assert.deepEqual(cfg.mcpServers.mot.args.slice(-1), ['mcp']);
  assert.equal(cfg.mcpServers.mot.env[KEY_ENV], KEY);
  assert.ok(existsSync(join(home, '.mot', 'mot3r.mjs')), 'bridge copied for Claude Desktop');
  assert.ok(!desktop.detail.includes(KEY));
});

test('install leaves a broken config untouched and reports it', () => {
  const { home, env } = tempHome();
  mkdirSync(join(home, '.cursor'), { recursive: true });
  writeFileSync(join(home, '.cursor', 'mcp.json'), '{ broken');
  const [row] = install({ hosts: ['cursor'], env });
  assert.equal(row.status, 'error');
  assert.equal(readFileSync(join(home, '.cursor', 'mcp.json'), 'utf8'), '{ broken');
});

test('Claude Code goes through `claude mcp add` with the key as a reference', () => {
  const { env } = tempHome();
  const dir = mkdtempSync(join(tmpdir(), 'mot3r-bin-'));
  const bin = join(dir, process.platform === 'win32' ? 'claude.exe' : 'claude');
  writeFileSync(bin, '');
  const calls = [];
  const rows = install({ hosts: ['claude-code'], env: { ...env, PATH: dir, PATHEXT: '.EXE' }, run: (b, args) => (calls.push(args), { ok: true, out: '' }) });
  assert.equal(rows[0].status, 'written');
  const add = calls.find((a) => a[1] === 'add');
  assert.deepEqual(add.slice(0, 7), ['mcp', 'add', '--transport', 'http', '--scope', 'user', 'mot']);
  assert.ok(add.includes('Authorization: Bearer ${MOT_KEY}'));
});

test('parseSse returns each event payload', () => {
  assert.deepEqual(parseSse('event: message\ndata: {"a":1}\n\ndata: {"b":2}\n\n'), ['{"a":1}', '{"b":2}']);
});

test('runShim forwards stdin to the endpoint with the bearer key and writes JSON and SSE answers', async () => {
  const seen = [];
  const fetchImpl = async (url, init) => {
    const msg = JSON.parse(init.body);
    seen.push({ url, headers: init.headers, msg });
    if (msg.method === 'initialize') return fakeResponse(200, JSON.stringify({ jsonrpc: '2.0', id: msg.id, result: { protocolVersion: '2025-06-18' } }));
    if (msg.method === 'notifications/initialized') return fakeResponse(202, '');
    return fakeResponse(200, `event: message\ndata: ${JSON.stringify({ jsonrpc: '2.0', id: msg.id, result: { tools: [] } })}\n\n`, 'text/event-stream');
  };
  const out = sink();
  const input = Readable.from([
    '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}\n',
    '{"jsonrpc":"2.0","method":"notifications/initialized"}\n',
    '{"jsonrpc":"2.0","id":2,"method":"tools/list"}\n',
    'not json\n',
  ]);
  await runShim({ url: DEFAULT_URL, key: KEY, input, output: out.stream, errors: sink().stream, fetchImpl });
  const lines = out.lines().map((l) => JSON.parse(l));
  assert.equal(lines.find((l) => l.id === 1).result.protocolVersion, '2025-06-18');
  assert.deepEqual(lines.find((l) => l.id === 2).result, { tools: [] });
  assert.equal(lines.find((l) => l.error?.code === -32700).id, null);
  assert.equal(lines.length, 3, 'a notification gets no answer');
  assert.ok(seen.every((s) => s.headers.authorization === `Bearer ${KEY}`));
  assert.equal(seen.find((s) => s.msg.id === 2).headers['mcp-protocol-version'], '2025-06-18');
});

test('runShim answers a JSON-RPC error when the endpoint is unreachable or not JSON', async () => {
  const out = sink();
  let n = 0;
  const fetchImpl = async () => {
    if (n++ === 0) throw new Error('ECONNREFUSED');
    return fakeResponse(502, '<html>bad gateway</html>', 'text/html');
  };
  const input = Readable.from(['{"jsonrpc":"2.0","id":7,"method":"tools/list"}\n', '{"jsonrpc":"2.0","id":8,"method":"tools/list"}\n']);
  await runShim({ url: DEFAULT_URL, key: KEY, input, output: out.stream, errors: sink().stream, fetchImpl });
  const lines = out.lines().map((l) => JSON.parse(l));
  assert.equal(lines.length, 2);
  assert.ok(lines.every((l) => l.error?.code === -32000));
});

test('runShim without a key warns on stderr and sends no authorization header', async () => {
  const err = sink();
  let headers;
  const fetchImpl = async (_u, init) => ((headers = init.headers), fakeResponse(200, '{"jsonrpc":"2.0","id":1,"result":{}}'));
  await runShim({ url: DEFAULT_URL, key: '', input: Readable.from(['{"jsonrpc":"2.0","id":1,"method":"tools/list"}\n']), output: sink().stream, errors: err.stream, fetchImpl });
  assert.equal(headers.authorization, undefined);
  assert.match(err.lines().join('\n'), /MOT_KEY is not set/);
});

test('doctor reports endpoint, tool count and key kind without printing the key', async () => {
  const fetchImpl = async (_u, init) => {
    const msg = JSON.parse(init.body);
    if (msg.method === 'initialize') return fakeResponse(200, JSON.stringify({ jsonrpc: '2.0', id: 1, result: { serverInfo: { name: 'mot', version: 'x' } } }));
    return fakeResponse(200, JSON.stringify({ jsonrpc: '2.0', id: 2, result: { tools: [{}, {}, {}] } }));
  };
  const logged = [];
  const rows = await doctor({ env: { [KEY_ENV]: KEY }, fetchImpl, log: (l) => logged.push(l) });
  assert.deepEqual(rows.map((r) => r[1]), ['ok', 'ok', 'ok']);
  assert.match(logged.join('\n'), /3 tools listed/);
  assert.ok(!logged.join('\n').includes(KEY));
});

test('keyKind recognises mot keys by prefix only', () => {
  assert.equal(keyKind(''), 'not set');
  assert.equal(keyKind(KEY), 'mot key (lk)');
  assert.equal(keyKind('sk-something-else'), 'unrecognised format');
});

test('parseArgs reads hosts, url and flags', () => {
  const a = parseArgs(['install', '--host', 'cursor, vscode', '--url=https://x/mcp', '--dry-run']);
  assert.deepEqual(a.hosts, ['cursor', 'vscode']);
  assert.equal(a.url, 'https://x/mcp');
  assert.equal(a.dryRun, true);
  assert.deepEqual(a._, ['install']);
});
