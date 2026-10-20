# mot3r

Installer and stdio bridge for the [mot](../../README.md) gateway. One file, `mot3r.mjs`. No dependencies.
Node.js 18 or newer. MIT.

```bash
node mot3r.mjs install [--host claude-code,claude-desktop,cursor,vscode] [--url URL] [--dry-run]
node mot3r.mjs print <client>     # one client's config, nothing written
node mot3r.mjs mcp                # stdio <-> https://mcp.mot3r.com/mcp
node mot3r.mjs doctor             # endpoint, tool count, key format (the key is never printed)
node mot3r.mjs hosts              # supported clients
```

After the one-line installer the file lives at `~/.mot/mot3r.mjs` (`%USERPROFILE%\.mot\mot3r.mjs` on Windows).

## What `install` writes

| Client | Where | How the key gets there |
|---|---|---|
| Claude Code | `claude mcp add --scope user` | `${MOT_KEY}`, expanded by Claude Code at start |
| Claude Desktop | `claude_desktop_config.json` | `env.MOT_KEY` in the file; the entry starts `~/.mot/mot3r.mjs mcp` |
| Cursor | `~/.cursor/mcp.json` | `${env:MOT_KEY}`, filled by Cursor |
| VS Code | user `mcp.json` | `${input:mot-key}`, asked once, kept in VS Code's secret store |

Every file it changes is backed up first (`<file>.mot-backup-<time>`). Other servers in the file stay. A file
that is not plain JSON is left untouched and reported. `--dry-run` prints the result with a placeholder in place
of the key.

## The bridge

`mot3r mcp` reads newline-delimited JSON-RPC on stdin, posts each message to the endpoint with
`Authorization: Bearer $MOT_KEY`, and writes each answer to stdout. `MOT_MCP_URL` or `--url` points it at
another https address. Without a key it still lists tools. Every `tools/call` then answers 401.

## Environment

| Variable | Meaning |
|---|---|
| `MOT_KEY` | the key (`mot_lk_live_xxxxxxxx`, `mot_tk_test_xxxxxxxx`, ...) |
| `MOT_MCP_URL` | endpoint for `mcp`, default `https://mcp.mot3r.com/mcp` |
| `MOT_HOME` | where the bridge is copied, default `~/.mot` |

## npm

mot3r 0.3.3 is not published to npm. Run it from a clone, or through `install/install.sh` or
`install/install.ps1`, which embed this file byte for byte.

## Tests

```bash
node --test test/mot3r.test.mjs
```

No network. Every HTTP call in the tests goes to a fake `fetch`.
