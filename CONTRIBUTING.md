# Contributing

Thanks for helping. This repository is the client side of mot: the installer and stdio bridge, the
examples and the docs.

## Before you start

- Bugs and small fixes: open a pull request directly.
- Anything larger, or a new client in the installer: open an issue first and say what you want to change.
- The hosted service is not in this repository. Problems with the endpoint itself go into an issue with the
  exact request and the JSON-RPC answer (without your key).

## Set up

```bash
git clone https://github.com/Hei33enberg/mot-os.git
cd mot-os
pnpm install          # there are no dependencies; this only links the workspace
pnpm test             # installer tests + installers in sync with packages/mot3r
pnpm check:examples   # the examples parse
```

Node.js 18 or newer. `pnpm test` needs no network and no key.

## Rules

- **Zero dependencies** in `packages/mot3r`. It must run from a single file with plain `node`.
- **Installers are generated.** After you change `packages/mot3r/mot3r.mjs`, run `pnpm build:installers` and
  commit `install/` with it. `pnpm test` fails when they drift.
- **Never print a key.** Every new output path goes through `redact()`; add a test that proves it.
- **Docs say what works today.** No feature goes into the docs before the endpoint serves it.
- **English only**, in code, comments and docs.
- **One concern per pull request**, with a clear commit message (`feat(mot3r): ...`, `docs: ...`).

## Commit sign-off

Sign your commits (`git commit -s`) to certify you wrote the change or have the right to submit it under MIT
([Developer Certificate of Origin](https://developercertificate.org)).

## Working with an AI agent

Welcome. Read [AGENTS.md](./AGENTS.md) and say in the pull request which agent helped.
