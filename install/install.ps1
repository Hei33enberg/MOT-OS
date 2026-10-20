# mot installer 0.3.3. MIT License. Wires the mot gateway into every MCP client on this machine.
#   irm <raw url of this file> | iex
# Requires Node.js 18 or newer. Copies mot3r.mjs to %USERPROFILE%\.mot (MOT_HOME) and runs `mot3r install`.
$ErrorActionPreference = 'Stop'

$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) { Write-Error 'mot: Node.js 18 or newer is required (https://nodejs.org).'; return }
$major = [int](& node -p 'parseInt(process.versions.node)')
if ($major -lt 18) { Write-Error "mot: Node.js 18 or newer is required, found $(& node --version)."; return }

$dir = if ($env:MOT_HOME) { $env:MOT_HOME } else { Join-Path $env:USERPROFILE '.mot' }
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$file = Join-Path $dir 'mot3r.mjs'
$src = @'
// mot3r - put mot into your MCP client. MIT License, zero dependencies, Node.js >= 18.
// Run it as `node mot3r.mjs <command>` or through the npm bin (bin/mot3r.mjs).
//
//   mot3r install [--host a,b] [--url URL] [--dry-run]   write the mot entry into your MCP clients
//   mot3r print <host>                                   print one client's config, write nothing
//   mot3r mcp                                            stdio <-> Streamable HTTP bridge (clients that only run local servers)
//   mot3r doctor                                         check the endpoint, the tool count and the MOT_KEY format (never prints the key)
//   mot3r hosts                                          list supported clients
//
// The key lives in the MOT_KEY environment variable. Clients that can read a variable get a reference to it,
// never the key itself. The one exception is Claude Desktop: it starts local servers from its config file, and
// that file's env block is the documented place for their environment (the installer says so when it writes it).
// Nothing this file prints carries the key: dry runs show a placeholder and every report line is redacted.
// install/install.sh and install/install.ps1 embed this file verbatim (scripts/build-installers.mjs).

import { existsSync, readFileSync, writeFileSync, mkdirSync, copyFileSync, statSync } from 'node:fs';
import { homedir, platform as osPlatform } from 'node:os';
import { join, dirname, delimiter, resolve } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { spawnSync } from 'node:child_process';
import { createInterface } from 'node:readline';

export const VERSION = '0.3.3';
export const DEFAULT_URL = 'https://mcp.mot3r.com/mcp';
export const KEY_ENV = 'MOT_KEY';
export const SERVER_NAME = 'mot';
export const KEY_PAGE = 'https://mot3r.com/panel/';
export const KEY_HIDDEN = '<value of MOT_KEY, hidden>';
export const VSCODE_INPUT = Object.freeze({ type: 'promptString', id: 'mot-key', description: 'mot key (mot_...)', password: true });
const UTF8_BOM = new RegExp('^' + String.fromCharCode(0xfeff));

/** Where configs live. MOT_USER_HOME and MOT_HOME exist for tests and portable setups. */
export function envPaths(env = process.env, plat = osPlatform()) {
  const home = env.MOT_USER_HOME || homedir();
  const appData = env.APPDATA || join(home, 'AppData', 'Roaming');
  const xdg = env.XDG_CONFIG_HOME || join(home, '.config');
  return { home, appData, xdg, plat, motHome: env.MOT_HOME || join(home, '.mot') };
}

/** The MCP endpoint. Only https, except http on a loopback address (tests, local proxies). */
export function resolveUrl(raw) {
  const url = new URL(raw || DEFAULT_URL);
  const loopback = ['localhost', '127.0.0.1', '[::1]'].includes(url.hostname);
  if (url.protocol !== 'https:' && !(url.protocol === 'http:' && loopback)) {
    throw new Error(`refusing ${url.protocol}// endpoint ${url.href}: mot keys travel only over https`);
  }
  return url.href;
}

// --- client catalogue ---------------------------------------------------------------------------

const bearer = (ref) => ({ Authorization: `Bearer ${ref}` });

/** The server entry each client expects. Claude Desktop goes through the local stdio bridge in this file. */
export const HOSTS = {
  'claude-code': {
    title: 'Claude Code',
    kind: 'cli',
    command: (url) => ['claude', 'mcp', 'add', '--transport', 'http', '--scope', 'user', SERVER_NAME, url, '--header', `Authorization: Bearer \${${KEY_ENV}}`],
    note: `Claude Code expands \${${KEY_ENV}} from the environment when it starts; the key is not stored in its config.`,
  },
  'claude-desktop': {
    title: 'Claude Desktop',
    kind: 'json',
    path: ['mcpServers', SERVER_NAME],
    files: (p) =>
      p.plat === 'win32'
        ? [join(p.appData, 'Claude', 'claude_desktop_config.json')]
        : p.plat === 'darwin'
          ? [join(p.home, 'Library', 'Application Support', 'Claude', 'claude_desktop_config.json')]
          : [join(p.xdg, 'Claude', 'claude_desktop_config.json')],
    entry: (url, ctx) => ({
      command: ctx.node,
      args: [ctx.shim, 'mcp'],
      env: { ...(ctx.key ? { [KEY_ENV]: ctx.key } : {}), ...(url !== DEFAULT_URL ? { MOT_MCP_URL: url } : {}) },
    }),
    note: 'Claude Desktop starts local (stdio) servers from its config file, so mot runs through the mot3r bridge. Restart Claude Desktop to load it.',
  },
  cursor: {
    title: 'Cursor',
    kind: 'json',
    path: ['mcpServers', SERVER_NAME],
    files: (p) => [join(p.home, '.cursor', 'mcp.json')],
    entry: (url) => ({ url, headers: bearer(`\${env:${KEY_ENV}}`) }),
    note: `Cursor fills \${env:${KEY_ENV}} itself when it reads mcp.json.`,
  },
  vscode: {
    title: 'VS Code',
    kind: 'vscode',
    // The user-profile mcp.json ("MCP: Open User Configuration"), next to settings.json.
    files: (p) => [
      p.plat === 'win32'
        ? join(p.appData, 'Code', 'User', 'mcp.json')
        : p.plat === 'darwin'
          ? join(p.home, 'Library', 'Application Support', 'Code', 'User', 'mcp.json')
          : join(p.xdg, 'Code', 'User', 'mcp.json'),
    ],
    entry: (url) => ({ type: 'http', url, headers: bearer(`\${input:${VSCODE_INPUT.id}}`) }),
    note: `VS Code asks for the key once (password prompt) and keeps it in its secret storage; mcp.json holds only \${input:${VSCODE_INPUT.id}}.`,
  },
};

// --- config writers (pure: text in -> text out) -------------------------------------------------

/** Merge `value` at `path` into a JSON document. Throws on anything that is not a JSON object. */
export function mergeJson(text, path, value) {
  const src = (text ?? '').replace(UTF8_BOM, '');
  let doc = {};
  if (src.trim()) {
    try {
      doc = JSON.parse(src);
    } catch (e) {
      throw new Error(`not plain JSON (${e.message}); left untouched`);
    }
    if (!doc || typeof doc !== 'object' || Array.isArray(doc)) throw new Error('top level is not a JSON object; left untouched');
  }
  let node = doc;
  for (const k of path.slice(0, -1)) {
    if (node[k] === undefined) node[k] = {};
    if (!node[k] || typeof node[k] !== 'object' || Array.isArray(node[k])) throw new Error(`"${k}" is not an object; left untouched`);
    node = node[k];
  }
  node[path[path.length - 1]] = value;
  return JSON.stringify(doc, null, 2) + '\n';
}

/** VS Code mcp.json: servers.<name> plus the input that holds the key (replaced by id, never duplicated). */
export function mergeVscode(text, name, entry, input = VSCODE_INPUT) {
  const doc = JSON.parse(mergeJson(text, ['servers', name], entry));
  if (doc.inputs !== undefined && !Array.isArray(doc.inputs)) throw new Error('"inputs" is not an array; left untouched');
  doc.inputs = [...(doc.inputs || []).filter((i) => !(i && i.id === input.id)), { ...input }];
  return JSON.stringify(doc, null, 2) + '\n';
}

/** Replace every occurrence of the key in a report string. */
export function redact(text, key) {
  return key && typeof text === 'string' ? text.split(key).join(KEY_HIDDEN) : text;
}

export function which(cmd, env = process.env) {
  const win = osPlatform() === 'win32';
  const exts = win ? ['', ...(env.PATHEXT || '.EXE;.CMD;.BAT').split(';').map((e) => e.toLowerCase())] : [''];
  for (const dir of (env.PATH || env.Path || '').split(delimiter)) {
    if (!dir) continue;
    for (const ext of exts) {
      try {
        if (statSync(join(dir, cmd + ext)).isFile()) return join(dir, cmd + ext);
      } catch {}
    }
  }
  return null;
}

/** Clients that look installed on this machine. */
export function detectHosts(env = process.env) {
  const p = envPaths(env);
  const found = [];
  if (which('claude', env) || existsSync(join(p.home, '.claude.json'))) found.push('claude-code');
  if (HOSTS['claude-desktop'].files(p).some((f) => existsSync(dirname(f)))) found.push('claude-desktop');
  if (existsSync(join(p.home, '.cursor'))) found.push('cursor');
  if (which('code', env) || existsSync(dirname(HOSTS.vscode.files(p)[0]))) found.push('vscode');
  return found;
}

function shellQuote(a) {
  return /^[\w@%+=:,./-]+$/.test(a) ? a : `'${a.replace(/'/g, `'\\''`)}'`;
}

/** Render one client's config as text (what `mot3r print` shows and what install writes). */
export function renderHost(id, { url = DEFAULT_URL, ctx = {} } = {}) {
  const h = HOSTS[id];
  if (!h) throw new Error(`unknown client "${id}" - try: ${Object.keys(HOSTS).join(', ')}`);
  if (h.kind === 'cli') return h.command(url).map(shellQuote).join(' ');
  const entry = h.entry(url, { node: 'node', shim: join(envPaths().motHome, 'mot3r.mjs'), key: '<your mot key>', ...ctx });
  if (h.kind === 'vscode') return mergeVscode('', SERVER_NAME, entry).trim();
  return mergeJson('', h.path, entry).trim();
}

function backup(file) {
  const to = `${file}.mot-backup-${new Date().toISOString().replace(/[:.]/g, '-')}`;
  copyFileSync(file, to);
  return to;
}

/** Copy this file to ~/.mot/mot3r.mjs so Claude Desktop can start the bridge without npm. */
export function installShim(p, self = fileURLToPath(import.meta.url)) {
  const target = join(p.motHome, 'mot3r.mjs');
  mkdirSync(p.motHome, { recursive: true });
  if (resolve(self) !== resolve(target)) writeFileSync(target, readFileSync(self));
  return target;
}

function runCli(bin, args) {
  const shell = /\.(cmd|bat)$/i.test(bin);
  const r = spawnSync(shell ? `"${bin}"` : bin, shell ? args.map((a) => (/[\s"]/.test(a) ? `"${a.replace(/"/g, '\\"')}"` : a)) : args, {
    encoding: 'utf8',
    shell,
    timeout: 60_000,
  });
  return { ok: r.status === 0, out: `${r.stdout || ''}${r.stderr || ''}`.trim() || String(r.error || r.status) };
}

/**
 * Write the mot entry for each client. Returns one report row per client and file; never throws for a
 * single client (a broken config is reported and left untouched).
 */
export function install({ hosts, url = DEFAULT_URL, env = process.env, dryRun = false, run = runCli } = {}) {
  url = resolveUrl(url);
  const p = envPaths(env);
  const list = hosts?.length ? hosts : detectHosts(env);
  const key = env[KEY_ENV] || '';
  const ctx = { node: process.execPath, shim: join(p.motHome, 'mot3r.mjs'), key: dryRun && key ? KEY_HIDDEN : key };
  const rows = [];
  for (const id of list) {
    const h = HOSTS[id];
    if (!h) {
      rows.push({ host: id, status: 'error', detail: `unknown client - try: ${Object.keys(HOSTS).join(', ')}` });
      continue;
    }
    try {
      if (h.kind === 'cli') {
        const argv = h.command(url);
        const bin = which(argv[0], env);
        if (!bin || dryRun) {
          rows.push({ host: id, status: dryRun ? 'dry-run' : 'manual', detail: `run: ${argv.map(shellQuote).join(' ')}` });
          continue;
        }
        run(bin, ['mcp', 'remove', '--scope', 'user', SERVER_NAME]); // a previous "mot" entry is replaced, not duplicated
        const r = run(bin, argv.slice(1));
        rows.push({ host: id, status: r.ok ? 'written' : 'error', detail: r.ok ? h.note : `claude mcp add failed: ${r.out}` });
        continue;
      }
      if (id === 'claude-desktop' && !dryRun) installShim(p);
      const entry = h.entry(url, ctx);
      for (const file of h.files(p, env)) {
        const before = existsSync(file) ? readFileSync(file, 'utf8') : '';
        const after = h.kind === 'vscode' ? mergeVscode(before, SERVER_NAME, entry) : mergeJson(before, h.path, entry);
        if (dryRun) {
          rows.push({ host: id, status: 'dry-run', file, detail: after });
          continue;
        }
        const saved = before ? backup(file) : null;
        mkdirSync(dirname(file), { recursive: true });
        writeFileSync(file, after);
        const warn = id === 'claude-desktop' ? (key ? ' The key is stored in this file (env block).' : ` ${KEY_ENV} was not set: add it to the env block, then restart Claude Desktop.`) : '';
        rows.push({ host: id, status: 'written', file, backup: saved, detail: h.note + warn });
      }
    } catch (e) {
      rows.push({ host: id, status: 'error', detail: `${e.message}. Paste by hand:\n${renderHost(id, { url })}` });
    }
  }
  for (const r of rows) for (const f of ['detail', 'file', 'backup']) r[f] = redact(r[f], key);
  return rows;
}

// --- stdio bridge -------------------------------------------------------------------------------

/** Split a text/event-stream body into the data payload of each event. */
export function parseSse(body) {
  const msgs = [];
  let data = [];
  for (const line of body.split(/\r?\n/)) {
    if (line === '') {
      if (data.length) msgs.push(data.join('\n'));
      data = [];
    } else if (line.startsWith('data:')) data.push(line.slice(5).replace(/^ /, ''));
  }
  if (data.length) msgs.push(data.join('\n'));
  return msgs;
}

const rpcError = (id, code, message, data) => JSON.stringify({ jsonrpc: '2.0', id: id ?? null, error: { code, message, ...(data ? { data } : {}) } });

/**
 * Bridge newline-delimited JSON-RPC on stdin to the Streamable HTTP endpoint and write every response
 * line to stdout. Resolves when stdin closes and every request in flight is answered.
 */
export async function runShim({
  url = process.env.MOT_MCP_URL,
  key = process.env[KEY_ENV],
  input = process.stdin,
  output = process.stdout,
  errors = process.stderr,
  fetchImpl = globalThis.fetch,
} = {}) {
  const target = resolveUrl(url);
  const state = { session: null, protocol: null };
  const write = (s) => output.write(s.endsWith('\n') ? s : s + '\n');
  if (!key) errors.write(`mot3r: ${KEY_ENV} is not set - tools/list works without a key, every tools/call returns 401. Get a key in the mot3r panel: ${KEY_PAGE}\n`);

  async function forward(line) {
    let msg;
    try {
      msg = JSON.parse(line);
    } catch {
      write(rpcError(null, -32700, 'Parse error: stdin line is not JSON'));
      return;
    }
    const first = Array.isArray(msg) ? msg[0] : msg;
    const id = first && 'id' in first && first.method ? first.id : undefined;
    const headers = { 'content-type': 'application/json', accept: 'application/json, text/event-stream' };
    if (key) headers.authorization = `Bearer ${key}`;
    if (state.protocol) headers['mcp-protocol-version'] = state.protocol;
    if (state.session) headers['mcp-session-id'] = state.session;
    let res;
    try {
      res = await fetchImpl(target, { method: 'POST', headers, body: line });
    } catch (e) {
      if (id !== undefined) write(rpcError(id, -32000, `mot endpoint unreachable: ${e.message}`));
      return;
    }
    const sid = res.headers.get('mcp-session-id');
    if (sid) state.session = sid;
    if (res.status === 202 || res.status === 204) return;
    const type = res.headers.get('content-type') || '';
    const body = await res.text();
    let forwarded = false;
    for (const b of type.includes('text/event-stream') ? parseSse(body) : [body]) {
      if (!b.trim()) continue;
      try {
        const parsed = JSON.parse(b);
        for (const m of Array.isArray(parsed) ? parsed : [parsed]) {
          if (first?.method === 'initialize' && m?.id === id && m?.result?.protocolVersion) state.protocol = m.result.protocolVersion;
        }
        write(JSON.stringify(parsed));
        forwarded = true;
      } catch {}
    }
    if (!forwarded && id !== undefined) write(rpcError(id, -32000, `mot endpoint answered HTTP ${res.status}`, { status: res.status, body: body.slice(0, 300) }));
  }

  // Everything after an `initialize` waits for its answer, so the protocol version is known before the next POST.
  const pending = new Set();
  let initialized = Promise.resolve();
  const rl = createInterface({ input, crlfDelay: Infinity });
  for await (const raw of rl) {
    const line = raw.trim();
    if (!line) continue;
    const isInit = /"method"\s*:\s*"initialize"/.test(line);
    const gate = initialized;
    const p = (isInit ? forward(line) : gate.then(() => forward(line))).catch((e) => errors.write(`mot3r: ${e.message}\n`));
    if (isInit) initialized = p;
    pending.add(p);
    p.finally(() => pending.delete(p));
  }
  await Promise.all([...pending]);
}

// --- doctor -------------------------------------------------------------------------------------

/** What a key looks like, by prefix. Never returns the key. */
export function keyKind(key) {
  if (!key) return 'not set';
  return /^mot_[a-z]{2}_[A-Za-z0-9_]+$/.test(key) ? `mot key (${key.slice(4, 6)})` : 'unrecognised format';
}

/** Check that the endpoint answers initialize and tools/list, and whether a key is set. Never prints the key. */
export async function doctor({ url = DEFAULT_URL, env = process.env, fetchImpl = globalThis.fetch, log = console.log } = {}) {
  url = resolveUrl(url);
  const rows = [];
  const call = async (body) => {
    const r = await fetchImpl(url, {
      method: 'POST',
      headers: { 'content-type': 'application/json', accept: 'application/json, text/event-stream' },
      body: JSON.stringify(body),
    });
    const t = await r.text();
    return (r.headers.get('content-type') || '').includes('event-stream') ? JSON.parse(parseSse(t)[0]) : JSON.parse(t);
  };
  try {
    const init = await call({ jsonrpc: '2.0', id: 1, method: 'initialize', params: { protocolVersion: '2025-06-18', capabilities: {}, clientInfo: { name: 'mot3r-doctor', version: VERSION } } });
    rows.push(['endpoint', 'ok', `${url} -> ${init.result?.serverInfo?.name} ${init.result?.serverInfo?.version}`]);
    const list = await call({ jsonrpc: '2.0', id: 2, method: 'tools/list' });
    rows.push(['tools', 'ok', `${list.result?.tools?.length ?? 0} tools listed`]);
  } catch (e) {
    rows.push(['endpoint', 'error', `${url}: ${e.message}`]);
  }
  const kind = keyKind(env[KEY_ENV] || '');
  rows.push(['key', kind.startsWith('mot key') ? 'ok' : 'warn', `${KEY_ENV}: ${kind}${env[KEY_ENV] ? '' : ` - get one at ${KEY_PAGE}`}`]);
  for (const r of rows) log(`${r[1].padEnd(5)} ${r[0].padEnd(8)} ${r[2]}`);
  return rows;
}

// --- CLI ----------------------------------------------------------------------------------------

export function parseArgs(argv) {
  const out = { _: [] };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--dry-run') out.dryRun = true;
    else if (a === '--host' || a === '--hosts') out.hosts = (argv[++i] || '').split(',').map((s) => s.trim()).filter(Boolean);
    else if (a.startsWith('--host=')) out.hosts = a.slice(7).split(',').filter(Boolean);
    else if (a === '--url') out.url = argv[++i];
    else if (a.startsWith('--url=')) out.url = a.slice(6);
    else if (a === '-h' || a === '--help') out.help = true;
    else if (a === '-v' || a === '--version') out.version = true;
    else out._.push(a);
  }
  return out;
}

const HELP = `mot3r ${VERSION} - put mot into your MCP client.

  mot3r install [--host ${Object.keys(HOSTS).join(',')}] [--url URL] [--dry-run]
                        write the mot entry into your MCP clients
  mot3r print <client>  show one client's config, write nothing
  mot3r mcp             stdio bridge to ${DEFAULT_URL} (reads ${KEY_ENV}, MOT_MCP_URL overrides the address)
  mot3r doctor          check the endpoint, the tool count and the key format (never prints the key)
  mot3r hosts           list supported clients

Get a key in the mot3r panel (${KEY_PAGE}) and put it in ${KEY_ENV}. MIT License.`;

export async function main(argv = process.argv.slice(2), log = console.log) {
  const a = parseArgs(argv);
  const cmd = a._[0];
  if (a.version) return log(VERSION);
  if (a.help || !cmd) return log(HELP);
  if (cmd === 'mcp') return runShim({ url: a.url || process.env.MOT_MCP_URL });
  if (cmd === 'hosts') return log(Object.entries(HOSTS).map(([id, h]) => `${id.padEnd(15)} ${h.title}`).join('\n'));
  if (cmd === 'print') return log(renderHost(a._[1], { url: resolveUrl(a.url) }));
  if (cmd === 'doctor') {
    const rows = await doctor({ url: a.url || DEFAULT_URL, log });
    if (rows.some((r) => r[1] === 'error')) process.exitCode = 1;
    return;
  }
  if (cmd === 'install') {
    if (!process.env[KEY_ENV]) log(`note: ${KEY_ENV} is not set. Clients read the key from this variable, so set it before you start them. Get a key in the mot3r panel: ${KEY_PAGE}`);
    const rows = install({ hosts: a.hosts, url: a.url, dryRun: a.dryRun });
    if (!rows.length) log(`No supported client found. Pick one: --host ${Object.keys(HOSTS).join(',')}`);
    for (const r of rows) {
      log(`\n[${r.status}] ${HOSTS[r.host]?.title || r.host}${r.file ? ` - ${r.file}` : ''}${r.backup ? ` (backup: ${r.backup})` : ''}`);
      if (r.detail) log(r.detail.replace(/^/gm, '  '));
    }
    if (rows.some((r) => r.status === 'error')) process.exitCode = 1;
    log('\nNext: restart the client, then ask it to call line_attach. Check anytime: mot3r doctor');
    return;
  }
  log(`unknown command "${cmd}"\n\n${HELP}`);
  process.exitCode = 2;
}

const invokedDirectly = (() => {
  try {
    return process.argv[1] && pathToFileURL(resolve(process.argv[1])).href === import.meta.url;
  } catch {
    return false;
  }
})();
if (invokedDirectly) {
  main().catch((e) => {
    console.error(`mot3r: ${e.message}`);
    process.exitCode = 1;
  });
}
'@
[System.IO.File]::WriteAllText($file, $src.Replace("`r`n", "`n") + "`n", (New-Object System.Text.UTF8Encoding $false))

& node $file install @args
