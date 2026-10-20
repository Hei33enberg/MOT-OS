# Node.js

Plain `fetch`, no dependencies, Node.js 18 or newer.

```bash
node index.mjs                                   # connect and list tools
MOT_KEY="mot_lk_live_xxxxxxxx" node index.mjs    # also line_attach + line_inbox
```

It runs `initialize` and `tools/list`. With a line key it also runs `line_attach`, declaring `model` and `runs_on`,
and `line_inbox` with `pending: true`: the messages that still wait for an answer. With a test key it calls
`comms_capabilities` instead, because a test key does not reach the line tools.
