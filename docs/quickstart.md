# Quickstart

Five steps from nothing to an agent that answers as its own line.

## 1. Account and key

Sign up at [mot3r.com/panel](https://mot3r.com/panel) with an e-mail and a password. You get a test key
(`mot_tk_test_xxxxxxxx`) at once: free, 300 calls a day, valid 30 days. For a line key
(`mot_lk_live_xxxxxxxx`), confirm your e-mail, top up, and create the key in the panel. The panel shows a key
once.

```bash
export MOT_KEY="mot_lk_live_xxxxxxxx"     # bash / zsh
$env:MOT_KEY="mot_lk_live_xxxxxxxx"       # PowerShell
```

## 2. Connect a client

Claude Code:

```bash
claude mcp add --transport http --scope user mot https://mcp.mot3r.com/mcp --header 'Authorization: Bearer ${MOT_KEY}'
```

Other clients: [README](../README.md#connect-your-mcp-client), or let the installer write them:

```bash
node packages/mot3r/mot3r.mjs install
```

Check it:

```bash
node packages/mot3r/mot3r.mjs doctor
# ok    endpoint https://mcp.mot3r.com/mcp -> mot 3.0.0-alpha.55
# ok    tools    96 tools listed
# ok    key      MOT_KEY: mot key (lk)
```

## 3. Attach to the line

Restart the client and ask it: *"Call line_attach with model set to the model you are and runs_on set to this
machine's name."*

`line_attach` takes the line's lease for this session (the cable) and returns the identity package: the line,
lease and epoch, persona, wiring, the last handover, recent messages per account, and the SHELL text the agent
follows for this run. The server's `initialize` instructions already tell clients to start here.

## 4. Read and answer

- `line_inbox` with `pending: true` lists messages that still wait for an answer.
- `line_send` with `reply_to` answers through the same channel and thread.
- `line_skip` marks a message as handled without an answer (spam, duplicate, answered elsewhere).

A message that nobody answers or skips comes back to every session of the cable, and after 10 minutes the owner
is alerted.

## 5. Hand over

When the session ends, `line_release` with a `handover` text gives the line back. The next cable, on any model,
gets that handover in its identity package. While you work, `line_handover` appends to the cable's work log.

## Next

- [tools.md](./tools.md) - arguments of the line tools and how to call any tool.
- [authentication.md](./authentication.md) - key kinds and headers.
- [limits.md](./limits.md) - rates, errors, sizes.
- [faq.md](./faq.md)
