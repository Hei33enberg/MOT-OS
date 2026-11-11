# Install

The installer puts the **mot3r 0.3.4** client on a machine and points the hosts it finds at the live gate. It does not install product **0.3.9**. The gate stays at `https://mcp.mot3r.com/mcp` and reports its own version. On 2026-11-11 that version was 0.3.9, with 97 tools.

You need a key first. Panel: [mot3r.com/panel](https://mot3r.com/panel/). A line key looks like `mot_lk_live_…`. A test key looks like `mot_tk_test_…` and cannot `line_attach`.

## One line

Node.js 18 or newer.

```bash
export MOT_KEY="mot_lk_live_xxxxxxxx"
curl -fsSL https://raw.githubusercontent.com/Hei33enberg/MOT-OS/main/install/install.sh | sh
```

```powershell
$env:MOT_KEY="mot_lk_live_xxxxxxxx"
irm https://raw.githubusercontent.com/Hei33enberg/MOT-OS/main/install/install.ps1 | iex
```

What that does:

1. Checks Node.js is 18 or newer.
2. Writes `mot3r.mjs` to `~/.mot` (`MOT_HOME` if you set it). The script embeds the client. The embedded `VERSION` is `0.3.4`.
3. Runs `mot3r install`, which writes the `mot` entry into each host it finds.

Flags, after `--`:

| Flag | Effect |
|---|---|
| `--dry-run` | prints the edits, writes no host config. The key is shown as a placeholder |
| `--host claude-code,cursor` | only those hosts |

Hosts the client knows: **Claude Code**, **Claude Desktop**, **Cursor**, **VS Code**. `node ~/.mot/mot3r.mjs hosts` prints the list from the file you just installed.

Claude Code, Cursor, and VS Code store a reference to `MOT_KEY`. Claude Desktop starts a local process, so its config holds the key in the `env` block. The installer says so when it writes that file. Dry-run output is redacted.

Restart the host after install. Then tell it to call `line_attach`.

## From a clone

```bash
node packages/mot3r/mot3r.mjs install
node packages/mot3r/mot3r.mjs install --dry-run
node packages/mot3r/mot3r.mjs doctor
```

`doctor` checks the endpoint, the tool count, and the shape of `MOT_KEY`. It never sends the key.

On npm, the published client is the same 0.3.4:

```bash
npx mot3r@0.3.4 install
```

## Do not edit the shell scripts by hand

`install/install.sh` and `install/install.ps1` are generated from `packages/mot3r/mot3r.mjs` by `scripts/build-installers.mjs`. Change the client, then:

```bash
node scripts/build-installers.mjs
pnpm test
```

`pnpm test` checks the installer tests and that the embedded copies still match `mot3r.mjs`.

## What install is not

- It is not a deploy of the gate.
- It is not a panel login.
- It does not top up m✲n3y. That is the panel, card via Polar, from 10 USD. See [PRICING.md](../PRICING.md).
