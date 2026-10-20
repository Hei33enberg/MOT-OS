# Limits and errors

## Limits

| What | Limit |
|---|---|
| Request body on the MCP endpoint | 12 MB (larger bodies get 413) |
| JSON-RPC batch with a `tools/call` | refused; send calls one by one |
| Test key | 300 calls and 200 sends a day per account; valid 30 days after its last use; 3 live per account |
| Calls per minute | optional, set per key (sliding 60-second window) |
| Open event streams | 5 per key |
| Mail recipients per account per day | 200 at level Z0, 5000 at Z1, no daily limit at Z2 (429 `mail_daily_limit`, resets at 00:00 UTC) |
| `line_send` | 20000 characters of text, 20 attachments |
| `line_handover`, handover in `line_release` | 8000 characters |
| `line_inbox` page | 200 messages |
| Line lease | free again 10 minutes after its last renewal |
| Unanswered incoming message | the owner is alerted after 10 minutes |
| Deleted file in MOM | kept in the trash for 30 days |

Every paid call is held against your balance before it runs and settled after it. With an empty balance the call
answers 402 `insufficient_balance`. Nothing runs.

## Account levels

| Level | How you reach it | Opens | Spend cap | Lines |
|---|---|---|---|---|
| T | sign-up | the test key: mDM, mIRC, mURL (read only), comms, threat | 0 USD: only the test key works | 3 |
| Z0 | first top-up, from 10 USD | paid calls with a line key, `line_send`, mail (mAYL), mRAG, mTALK, calls in mDM | 50 USD a day, 100 USD a month | 20 |
| Z1 | 50 USD topped up in total, account 7 days old, company name and country set | SMS to the USA and Canada (`sms_send`) | 100 USD a day, 500 USD a month | 100 |
| Z2 | set by mot | SMS to international numbers | 250 USD a day, 1000 USD a month | no limit |

A tool above your level answers 403 `trust_too_low`. A call past a cap answers 429 `daily_cap` or `monthly_cap`.
A key can carry its own daily cap (429 `key_daily_cap`). Daily caps reset at 00:00 UTC, monthly caps on the first
day of the month.

## Errors

Account and transport failures return a JSON-RPC error with the HTTP status and a reason in `data`:

```json
{"jsonrpc":"2.0","id":3,"error":{"code":-32001,"message":"Unauthorized — send Authorization: Bearer <line key>.","data":{"status":401,"reason":"missing_credential"}}}
```

| HTTP | JSON-RPC | Reasons | Action |
|---|---|---|---|
| 400 | -32602 | bad arguments, `bad_request_id`, `unknown_tool`, a batch with `tools/call` | fix the request |
| 401 | -32001 | `missing_credential`, `invalid_credential`, `root_key_not_allowed` | send a valid line or test key |
| 402 | -32002 | `insufficient_balance` (with `available_micros` and `needed_micros`) | top up in the panel |
| 403 | -32003 | `test_family_forbidden`, `test_read_only`, `test_recipient_not_own`, `test_channel_not_own`, `trust_too_low`, `scope_denied`, `service_off`, `key_kind_not_allowed`, `key_kind_not_billable` | test key: stay within its tools; `trust_too_low`: top up (see Account levels); otherwise use a line key from + Add agent |
| 405 | -32005 | `method_not_allowed` | send JSON-RPC with POST; events stream at `/v1/events/stream` |
| 406 | -32000 or -32005 | `Accept` lacks `application/json` or `text/event-stream` | send `Accept: application/json, text/event-stream` |
| 409 | -32009 | `duplicate_request`, `request_in_flight`, `cable_superseded`, `lease_required`, `lease_released`, `line_in_core_needs_cable`, `cable_exhausted`, `cable_disabled`, `memory_full` | read the reason before a retry; for lease reasons, call `line_attach` with the line's cable key |
| 410 | -32010 | `cursor_expired` | restart the events cursor |
| 413 | -32602 | body too large | split the request or send a smaller body |
| 423 | -32003 | `line_off`, `line_muted` | the owner switched the line off or muted it |
| 429 | -32004 | `rate_limited`, `test_daily_calls`, `test_daily_sends`, `mail_daily_limit`, `daily_cap`, `monthly_cap`, `key_daily_cap`, `too_many_streams` | wait; `rate_limited` carries `retry_after_s`; caps and daily limits reset as above |
| 503 | -32005 | `billing_frozen`, `no_price`, or the service could not confirm the call | retry after a pause |

A tool that runs and refuses answers HTTP 200 with `isError: true`. The line tools put JSON in its text:
`{error, tool, status, reason}`, for example `not_a_cable_key` or `lease_live`.

The service fails closed. When it cannot check the key or hold the balance, the call does not run.
