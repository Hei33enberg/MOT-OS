// mot from plain Node.js (18+), no dependencies.
//   node index.mjs                      lists the tools (no key needed)
//   MOT_KEY=mot_... node index.mjs      also plugs this script into the line and reads what waits in line_inbox
// Every tools/call draws from the balance behind the key. See PRICING.md.

const URL = process.env.MOT_MCP_URL || 'https://mcp.mot3r.com/mcp';
const KEY = process.env.MOT_KEY || '';
let nextId = 1;

async function rpc(method, params) {
  const res = await fetch(URL, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      accept: 'application/json, text/event-stream',
      ...(KEY ? { authorization: `Bearer ${KEY}` } : {}),
    },
    body: JSON.stringify({ jsonrpc: '2.0', id: nextId++, method, ...(params ? { params } : {}) }),
  });
  const text = await res.text();
  // The endpoint answers JSON; an event stream is unwrapped in case a proxy prefers it.
  const body = (res.headers.get('content-type') || '').includes('event-stream')
    ? text.split('\n').filter((l) => l.startsWith('data:')).map((l) => l.slice(5)).join('')
    : text;
  const msg = JSON.parse(body);
  if (msg.error) throw new Error(`${method}: ${msg.error.code} ${msg.error.message}`);
  return msg.result;
}

async function callTool(name, args = {}) {
  const result = await rpc('tools/call', { name, arguments: args });
  const text = (result.content || []).filter((c) => c.type === 'text').map((c) => c.text).join('\n');
  if (result.isError) throw new Error(`${name}: ${text}`);
  return result.structuredContent ?? JSON.parse(text);
}

const init = await rpc('initialize', {
  protocolVersion: '2025-06-18',
  capabilities: {},
  clientInfo: { name: 'mot-example-node', version: '0.3.3' },
});
console.log(`connected: ${init.serverInfo.name} ${init.serverInfo.version}`);

const { tools } = await rpc('tools/list');
console.log(`${tools.length} tools, line tools: ${tools.filter((t) => t.name.startsWith('line_')).map((t) => t.name).join(', ')}`);

if (!KEY) {
  console.log('Set MOT_KEY to attach to your line (key: https://mot3r.com).');
  process.exit(0);
}

const pack = await callTool('line_attach', { model: 'example-script', runs_on: 'laptop' });
console.log('attached:', JSON.stringify(pack).slice(0, 400));

const inbox = await callTool('line_inbox', { pending: true, limit: 10 });
console.log('waiting in the inbox:', JSON.stringify(inbox).slice(0, 400));
