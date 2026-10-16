# Contributing

This repository is the client side of mot: the installer and stdio bridge, the examples and the docs.

## Before you start

- Bugs and small fixes: open a pull request.
- Anything larger, or a new client in the installer: open an issue first. Say what changes and why.
- The hosted service is not in this repository. A problem with the endpoint goes into an issue with the exact
  request and the JSON-RPC answer. Never the key.

## Set up

```bash
git clone https://github.com/Hei33enberg/mot-os.git
cd mot-os
pnpm install          # no dependencies; this only links the packages
pnpm test             # installer tests + installers in sync with packages/mot3r
pnpm check:examples   # the examples parse
```

Node.js 18 or newer. `pnpm test` needs no network and no key.

## Rules

- **Zero dependencies** in `packages/mot3r`. It must run from a single file with plain `node`.
- **Installers are generated.** After you change `packages/mot3r/mot3r.mjs`, run `pnpm build:installers` and
  commit `install/` with it. `pnpm test` fails when they drift.
- **Never print a key.** Every new output path goes through `redact()`. Add a test that proves it.
- **Docs say what works today.** A feature enters the docs when the endpoint serves it, not before.
- **English only**, in code, comments and docs.
- **One concern per pull request**, with a clear commit message (`feat(mot3r): ...`, `docs: ...`).

## Commit sign-off

Sign your commits (`git commit -s`) to certify you wrote the change or have the right to submit it under MIT
([Developer Certificate of Origin](https://developercertificate.org)).

## Working with an agent

Read [AGENTS.md](./AGENTS.md). Name the agent in the pull request.
