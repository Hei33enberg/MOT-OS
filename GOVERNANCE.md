# Governance

mot has one lead maintainer. The lead maintainer has the final word on direction, scope, names and the brand.
Contributors propose and build. The lead maintainer decides and writes down why. There is no vote.

## Roles

**Contributors.** Anyone who opens an issue, reviews, or sends a pull request.

**Maintainers.** Contributors with merge rights, granted and revoked by the lead maintainer. Listed in
[MAINTAINERS.md](./MAINTAINERS.md).

**Lead maintainer.** Holds the final word and the trademark.

## Decisions

- **Routine changes** (fixes, docs, tests): a maintainer reviews and merges.
- **Larger changes** (a new command in `mot3r`, a new supported client, a change to how keys are handled): an
  issue first, open for comment for at least three days, then a decision written in the issue.
- **Security fixes** may land without the waiting period.

## Releases

Releases are cut by maintainers from their own machines. There is no CI pipeline.

- **npm client (`mot3r`)** — bump `version` in `package.json`, `packages/mot3r/package.json` and `VERSION` in
  `packages/mot3r/mot3r.mjs`, regenerate `install/`, tag `vX.Y.Z`, then publish. Do not bump these to match the
  hosted product unless you are publishing that client.
- **Hosted product** — versioned on mot3r.com (panel `wersja.json`). Public docs name that product version
  separately from the npm client.

## Forks

You may fork under MIT. Give the fork its own name and say it is a fork. See [TRADEMARK.md](./TRADEMARK.md).

## Changing this document

By pull request, decided by the lead maintainer.
