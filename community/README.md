# Community

This folder is the public ledger and the door into the Realm. The charter is [docs/realm.md](../docs/realm.md). The same charter is at the repository root as [REALM.md](../REALM.md).

## Where people talk

| Surface | Use it for |
|---|---|
| [GitHub Issues](https://github.com/Hei33enberg/MOT-OS/issues) | bugs in the client, the installer, the examples, the docs |
| [GitHub Discussions](https://github.com/Hei33enberg/MOT-OS/discussions) | how a line works, which host you are wiring |
| [SECURITY.md](../SECURITY.md) | a vulnerability. Not an issue |

There is no other official room. If a page names a chat that is not in this table, the page is wrong.

The hosted gate is not developed in this repository. An issue that asks to change metering, the panel, or the database belongs to the operator, not to a pull request here.

## The ledger

[realm.json](./realm.json) is the machine-readable list. Levels:

| Level | Title | Bar |
|---|---|---|
| L0 | Citizen | show up |
| L1 | Squire | one substantive merged pull request, or real triage |
| L2 | Knight | three or more |
| L3 | Baron / Baroness | maintainer, via [MAINTAINERS.md](../MAINTAINERS.md) |
| L4 | Herald | named by the Crown |

The founder is `crown`, outside the ladder. "Substantive" is a feature, a hard fix, or a deep refactor. Not a typo.

The human list is [HALL_OF_FAME.md](../HALL_OF_FAME.md).

## What a good contribution looks like

The client is `packages/mot3r` at **0.3.4**. The live gate is **0.3.9**. A doc change that mixes those two is a bug, not a cleanup.

Before you open the pull request:

- Words match [docs/words.md](../docs/words.md). `line` in the API, `tunnel` in the panel, `cable` for the model.
- Examples still run against `https://mcp.mot3r.com/mcp` and still refuse to pretend a test key can `line_attach`.
- Installer text stays generated. Edit `packages/mot3r/mot3r.mjs`, then `pnpm build:installers`. Do not hand-edit `install/install.sh`.
- You did not paste a key. Placeholders only: `mot_lk_live_xxxxxxxx`.

## Conduct

[CODE_OF_CONDUCT.md](../CODE_OF_CONDUCT.md). The license on the client is [MIT](../LICENSE). The name is not: [TRADEMARK.md](../TRADEMARK.md).
