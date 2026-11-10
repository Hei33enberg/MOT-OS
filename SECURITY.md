# Security

## Reporting a vulnerability

Do not open a public issue. Report privately through GitHub:
[Report a vulnerability](https://github.com/Hei33enberg/MOT-OS/security/advisories/new).

Include what you found, how to reproduce it, which version or endpoint is affected, and whether you plan to
publish a write-up. Never include a working key. If a key of yours leaked, say where, and revoke it in the panel.
If you found someone else's key, tell us where, and do not use it.

We acknowledge every report. Fixes go by severity, and we do not promise fixed deadlines. Reporters are credited
in the advisory unless they ask not to be. There is no paid bounty.

## Scope

In scope:

- this repository (`packages/mot3r`, `install/`, `examples/`)
- the hosts `mcp.mot3r.com`, `api.mot3r.com` and `mot3r.com`
- line mail at `mot.email`

Out of scope: services we do not run, social engineering, physical attacks, denial of service, and findings
already published without coordination.

## Supported versions

Only the latest release of this repository gets fixes.

## What the client does with your key

- `mot3r` reads the key from `MOT_KEY` and sends it only as `Authorization: Bearer`, over https. Loopback http is
  allowed for local tests.
- It writes references to the variable into client configs, never the key. The one exception is Claude Desktop:
  its config file holds the `env` block of local servers.
- Dry runs and reports replace the key with a placeholder.
