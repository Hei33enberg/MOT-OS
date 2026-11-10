# Realm

The Realm is the mot contributor community and its open ledger — people and agents who build the client, the docs, and the installers, and the rules for how that work is recognized.

One principle: **the crown holds the DNA, the realm holds the infrastructure.** The founder keeps the vision, the name, and the final word ([GOVERNANCE.md](./GOVERNANCE.md)); the community holds the running client, the mirrors, the merge rights, and the credit.

Titles below carry plain open-source equivalents. The theme is flavor; the rights are real.

## Roles

| Realm role | OSS equivalent | Rights | How you get it |
|---|---|---|---|
| **Citizen** | community member | read, post, participate in Discussions | show up |
| **Squire** | first-time contributor | listed in the ledger | first merged substantive PR |
| **Knight** | recognized contributor | row in the [Hall of Fame](./HALL_OF_FAME.md) | 3+ substantive PRs |
| **Baron / Baroness** | area maintainer | merge rights in an area | the [MAINTAINERS.md](./MAINTAINERS.md) path |
| **Herald** | ambassador / docs | official community voice | sustained propagation, named by the Crown |
| **Warden** | security researcher | Hall of Fame security lane | accepted disclosure per [SECURITY.md](./SECURITY.md) |
| **The Crown** | founder / BDFL | vision, final word, trademark | see [GOVERNANCE.md](./GOVERNANCE.md) |

## Levels

Levels are earned, public, and recorded in the ledger ([HALL_OF_FAME.md](./HALL_OF_FAME.md)). "Substantive" means features, hard bug fixes, deep refactors — not typo fixes, dependency bumps, or trivial cleanups.

| Level | Title | Criteria |
|---|---|---|
| **L0** | Citizen | joined — zero barrier |
| **L1** | Squire | 1 merged substantive PR, or sustained issue triage |
| **L2** | Knight | 3+ substantive PRs → Hall of Fame row |
| **L3** | Baron / Baroness | 5+ substantive PRs in one area over 3+ months → merge rights |
| **L4** | Herald | sustained propagation — talks, integrations, content — named by the Crown |

Agents climb the same ladder. A PR authored by (or with) an AI agent counts the same as any other — see [AGENTS.md](./AGENTS.md).

## What this repo is

This repository is the **client side** under MIT: installer, stdio bridge, examples, docs. The hosted gate at `mcp.mot3r.com` is not in this repository. Contributions here improve what every host installs; they do not open the hosted service.

## Words that stay fixed

Public text uses the mot lexicon. Full table: [docs/words.md](./docs/words.md).

| Word | Meaning |
|---|---|
| **line** | permanent agent identity |
| **cable** | model session on the line |
| **SHELL** | instructions returned by `line_attach` |
| **MOM** | line memory |
| **Ledger** | record of attaches, tool calls, vault reads |

The cable dies. The line lives. MOM remembers.
