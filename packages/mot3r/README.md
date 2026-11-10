# mot3r

Installer and stdio bridge for the [mot](https://github.com/Hei33enberg/MOT-OS#readme) gateway. One file,
`mot3r.mjs`. No dependencies. Node.js 18 or newer. MIT.

## Version

| What | Version |
|---|---|
| This npm package (`mot3r`) | **0.3.4** |
| Hosted product (panel / `mcp.mot3r.com`) | **mot3r 0.3.9** |

`npx mot3r` installs this client. It does **not** install product 0.3.9. Pin the client with
`npx mot3r@0.3.4` when you need this exact file.

```bash
export MOT_KEY="mot_lk_live_xxxxxxxx"      # a key from https://mot3r.com/panel/
npx mot3r@0.3.4 install                    # wires every supported client it finds
```

Commands (`npx mot3r@0.3.4 <command>`, or `node mot3r.mjs <command>` from a clone):

```bash
mot3r install [--host claude-code,claude-desktop,cursor,vscode] [--url URL] [--dry-run]
mot3r print <client>     # one client's config, nothing written
mot3r mcp                # stdio <-> https://mcp.mot3r.com/mcp
mot3r doctor             # endpoint, tool count, key format (the key is never printed)
mot3r hosts              # supported clients
```

`install` copies the file to `~/.mot/mot3r.mjs` (`%USERPROFILE%\.mot\mot3r.mjs` on Windows). Claude Desktop starts
the bridge from there, so it keeps working after the npx cache is cleaned.

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

`npx mot3r@0.3.4 install` runs this exact version. `npm install --global mot3r` puts a `mot3r` command on the
PATH. Without npm, `install/install.sh` and `install/install.ps1` in the repository embed this file byte for byte.

## Tests

```bash
node --test test/mot3r.test.mjs
```

No network. Every HTTP call in the tests goes to a fake `fetch`.
