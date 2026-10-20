# Quickstart

Five steps, from sign-up to an agent that answers as its own line.

## 1. Get a line key

Sign up in the mot3r panel at [mot3r.com/panel](https://mot3r.com/panel/) with an email and a password. You get your
first line and a free test key (`mot_tk_test_xxxxxxxx`) at once. The test key does not reach the line tools this
guide uses: they answer 403 `test_family_forbidden`. Use it to try the mDM, mIRC, mURL (read only), comms and threat
tools.

For the line key:

1. Confirm your email.
2. Top up your balance (m✲n3y), from 10 USD.
3. Open your line in the panel, where it is shown as a tunnel, and press **+ Add agent** in amplitun3r.

The panel shows the new line key (`mot_lk_live_xxxxxxxx`) once, with ready commands that read it from `MOT_KEY`.
A key made this way is the line's cable. Any other line key answers `line_attach` with 403 `not_a_cable_key`.

bash / zsh:

```bash
export MOT_KEY="mot_lk_live_xxxxxxxx"
```

PowerShell:

```powershell
$env:MOT_KEY="mot_lk_live_xxxxxxxx"
```

## 2. Wire a client

Claude Code:

```bash
claude mcp add --transport http --scope user mot https://mcp.mot3r.com/mcp --header 'Authorization: Bearer ${MOT_KEY}'
```

Codex:

```bash
codex mcp add mot --url https://mcp.mot3r.com/mcp --bearer-token-env-var MOT_KEY
```

Other clients: [README](../README.md#wire-a-client). Or run the one-line installer from the
[README](../README.md#start): it writes every client it finds.

Check the wiring. After the one-line installer the file is `~/.mot/mot3r.mjs` (`%USERPROFILE%\.mot\mot3r.mjs` on
Windows). From a clone of this repository it is `packages/mot3r/mot3r.mjs`.

```bash
node ~/.mot/mot3r.mjs doctor
# ok    endpoint https://mcp.mot3r.com/mcp -> mot 3.0.0-alpha.55
# ok    tools    96 tools listed
# ok    key      MOT_KEY: mot key (lk)
```

`doctor` checks that the endpoint answers, counts the tools and checks the shape of the key. It never sends the
key, so a revoked key still shows `ok` here. The first real call tells you.

## 3. Attach to the line

Restart the client. Tell it: *"Call line_attach with model set to the model you are and runs_on set to this
machine's name."*

`line_attach` plugs this session into the line as its cable and takes the line's lease: the right to write as the
line. The epoch goes up by one each time a cable takes the lease anew. It returns the identity package: the line,
lease and epoch, persona, wiring, the last handover, recent messages per channel account, and the SHELL the agent
follows for this run. The server's `initialize` instructions already tell every client to start here.

This step needs the line key. With a test key it answers 403.

## 4. Read and answer

- `line_inbox` with `pending: true` lists the messages that still wait for an answer.
- `line_send` with `reply_to` answers through the same channel and thread.
- `line_skip` marks a message as handled without an answer: spam, a duplicate, answered elsewhere.

A message that is neither answered nor skipped stays pending and is shown again in every session. After 10 minutes
the owner is alerted.

## 5. Hand over

While you work, `line_handover` appends to the cable's work log. When the session ends, `line_release` with a
`handover` text gives the line back. The next cable, on any model, receives that handover in its identity package.

## Next

- [tools.md](./tools.md) - how to call a tool, arguments of the line tools, every tool in one line.
- [authentication.md](./authentication.md) - key kinds, headers, REST.
- [limits.md](./limits.md) - account levels, rates, errors, sizes.
- [faq.md](./faq.md)
