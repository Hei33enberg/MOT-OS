# Limits and errors

## Limits

| What | Limit |
|---|---|
| Request body on the MCP endpoint | 12 MB (larger answers 413) |
| JSON-RPC batch with a `tools/call` | refused; send calls one by one |
| Test key | 300 calls a day, 30 days, 3 per account |
| Calls per minute | per key, when the key has a limit set (sliding 60-second window) |
| Open event streams | 5 per key |
| Mail sent by one line | 200 a day by default |
| `line_send` | 20000 characters of text, 20 attachments |
| `line_handover`, handover in `line_release` | 8000 characters |
| `line_inbox` page | 200 messages |
| Line lease | taken over after 10 minutes without renewal |
| Unanswered incoming message | the owner is alerted after 10 minutes |
| Deleted file in MOM | kept in the trash for 30 days |

Every paid call is held against the m✲n3y balance before it runs and settled after it. With an empty balance
the call answers 402. Nothing runs.

## Errors

Account and transport failures return a JSON-RPC error with the HTTP status and a reason in `data`:

```json
{"jsonrpc":"2.0","id":3,"error":{"code":-32001,"message":"Unauthorized - invalid or revoked hub key.","data":{"status":401,"reason":"invalid_credential"}}}
```

| HTTP | JSON-RPC | Reasons | Action |
|---|---|---|---|
| 400 | -32602 | bad arguments, a batch with `tools/call` | fix the request |
| 401 | -32001 | `missing_credential`, `invalid_credential`, `root_key_not_allowed` | send a valid line, agent or test key |
| 402 | -32002 | `insufficient_balance` | top up in the panel |
| 403 | -32003 | the key or the account level does not allow this tool | use a key with the right scope |
| 409 | -32009 | `duplicate_request`, `request_in_flight`, `cable_superseded`, `lease_required`, `lease_released`, `memory_full` | read the reason before a retry; for lease reasons, call `line_attach` |
| 410 | -32010 | `cursor_expired` | restart the events cursor |
| 413 | -32602 | body too large | send less |
| 423 | -32003 | `line_off`, `line_muted` | the owner switched the line off or muted it |
| 429 | -32004 | `rate_limited`, `test_daily_calls`, `mail_daily_limit`, `too_many_streams` | wait; `rate_limited` carries `retry_after_s` |
| 503 | -32005 | the service could not confirm the call | retry after a pause |

The service fails closed. When it cannot check the key or hold the balance, the call does not run.
