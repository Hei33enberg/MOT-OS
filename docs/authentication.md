# Authentication

Every `tools/call` carries a key in one header:

```
Authorization: Bearer mot_lk_live_xxxxxxxx
```

There is no other header and no key in the URL. `initialize` and `tools/list` work without a key.

## Key kinds

A key is `mot_<kind>_<mode>_` followed by 64 hex characters. The service stores only a hash; the panel shows a
new key once.

| Prefix | Kind | What it is for |
|---|---|---|
| `mot_lk_live_` | line | one line: MCP tools, balance, events |
| `mot_ak_live_` | agent | the whole account: a cable that is not pinned to one line |
| `mot_tk_test_` | test | free trial: MCP tools only, 300 calls a day, valid 30 days, at most 3 per account |
| `mot_sk_live_` | root | account management and tokens; refused on the MCP endpoint |
| `mot_ok_live_` | observe | read-only monitoring |

Use a line key or an agent key in MCP clients. Keep the root key out of them: the endpoint answers it with
401 `root_key_not_allowed`.

## Where the key lives

Put it in the `MOT_KEY` environment variable and let the client reference it:

| Client | Reference |
|---|---|
| Claude Code | `${MOT_KEY}` in `--header`, in single quotes so your shell does not expand it |
| Cursor | `${env:MOT_KEY}` |
| VS Code | `${input:mot-key}`, asked once and stored in VS Code's secret storage |
| Claude Desktop | `env.MOT_KEY` in `claude_desktop_config.json` (the file itself holds the key) |

Keys travel only over https. The bridge in `packages/mot3r` refuses any other scheme outside loopback.

## Revoking

Create, list, revoke and rotate keys in the panel at [mot3r.com/panel](https://mot3r.com/panel). A revoked key
answers 401 `invalid_credential` at once.

## REST with the same key

| Request | Host | Key |
|---|---|---|
| `GET /v1/balance` | `api.mot3r.com` | line or root |
| `GET /v1/usage?from=&to=&group_by=` | `api.mot3r.com` | line or root |
| `GET /v1/events?after=&limit=&types=` | `api.mot3r.com` | line or test |
| `GET /v1/events/stream` (server-sent events, `Last-Event-ID`) | `api.mot3r.com` | line or test |
| `GET /v1/pricing` | `api.mot3r.com` | none |
| `GET /v1/health` | `api.mot3r.com`, `mcp.mot3r.com` | none |

```bash
curl -sS https://api.mot3r.com/v1/balance -H "Authorization: Bearer $MOT_KEY"
```
