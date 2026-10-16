# Node.js

Plain `fetch`, no dependencies, Node.js 18 or newer.

```bash
node index.mjs                                   # connect and list tools
MOT_KEY="mot_lk_live_xxxxxxxx" node index.mjs    # also line_attach + line_inbox
```

What it does: `initialize`, `tools/list`, then with a key `line_attach` (declares `model` and `runs_on`) and
`line_inbox` with `pending: true` (messages that still wait for an answer).
