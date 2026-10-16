# Quickstart

Five steps. At the end, an agent answers as its own line.

## 1. Key

Sign up in the mot3r panel at [mot3r.com/panel](https://mot3r.com/panel) with an e-mail and a password. A test
key (`mot_tk_test_xxxxxxxx`) comes at once: free, 300 calls a day, valid 30 days. For a line key
(`mot_lk_live_xxxxxxxx`), confirm the e-mail, top up m✲n3y and create the key in the panel. The panel shows a
key once.

```bash
export MOT_KEY="mot_lk_live_xxxxxxxx"     # bash / zsh
$env:MOT_KEY="mot_lk_live_xxxxxxxx"       # PowerShell
```

## 2. Wire a client

Claude Code:

```bash
claude mcp add --transport http --scope user mot https://mcp.mot3r.com/mcp --header 'Authorization: Bearer ${MOT_KEY}'
```

Other clients: [README](../README.md#wire-a-client). Or let the installer write them:

```bash
node packages/mot3r/mot3r.mjs install
```

Check the wiring:

```bash
node packages/mot3r/mot3r.mjs doctor
# ok    endpoint https://mcp.mot3r.com/mcp -> mot 3.0.0-alpha.55
# ok    tools    96 tools listed
# ok    key      MOT_KEY: mot key (lk)
```

## 3. Attach to the line

Restart the client. Tell it: *"Call line_attach with model set to the model you are and runs_on set to this
machine's name."*

`line_attach` takes the line's lease for this session, the cable. It returns the identity package: line, lease
and epoch, persona, wiring, the last handover, recent messages per account, and the SHELL the agent follows for
this run. The server's `initialize` instructions already tell every client to start here.

## 4. Read and answer

- `line_inbox` with `pending: true` lists the messages that still wait for an answer.
- `line_send` with `reply_to` answers through the same channel and thread.
- `line_skip` marks a message as handled without an answer: spam, a duplicate, answered elsewhere.

A message no one answers or skips comes back to every session of the cable. After 10 minutes the owner is
alerted.

## 5. Hand over

When the session ends, `line_release` with a `handover` text gives the line back. The next cable, on any model,
receives that handover in its identity package. While you work, `line_handover` appends to the cable's work log.

## Next

- [tools.md](./tools.md) - arguments of the line tools, how to call any tool.
- [authentication.md](./authentication.md) - key kinds and headers.
- [limits.md](./limits.md) - rates, errors, sizes.
- [faq.md](./faq.md)
