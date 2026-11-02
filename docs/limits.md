# Limits and errors

## Limits

| What | Limit |
|---|---|
| MCP request body | 12 MB (413) |
| JSON-RPC batch with `tools/call` | refused — one call per request |
| Test key | 300 calls + 200 sends / day / account; 30 days after last use; 3 live keys |
| Open event streams | 5 per key |
| Mail recipients / day | 200 (Z0), 5000 (Z1), unlimited (Z2); reset 00:00 UTC |
| `line_send` text | 20 000 chars, up to 20 parts |
| `line_handover` / release handover | 8 000 chars |
| `line_inbox` page | 200 |
| Lease idle | free after 10 minutes without renewal |
| Unanswered inbound | owner alert after 10 minutes |
| MOM trash | 30 days |

Empty balance → `402 insufficient_balance` (nothing runs).

## Account levels

| Level | How | Opens | Caps | Lines |
|---|---|---|---|---|
| T | signup | test key families only | $0 paid | 3 |
| Z0 | first top-up (≥ $10) | line key, send, mail, mRAG, mTALK, mDM calls | $50/day, $100/mo | 20 |
| Z1 | $50 lifetime top-up, 7 days, company set | SMS US/CA | $100/day, $500/mo | 100 |
| Z2 | set by mot | SMS international | $250/day, $1000/mo | unlimited |

Above level → `403 trust_too_low`. Cap → `429 daily_cap` / `monthly_cap`.

## Errors

JSON-RPC error with `data.status` + `data.reason`. Common:

| HTTP | Reasons | Do |
|---|---|---|
| 401 | `missing_credential`, `invalid_credential` | send a valid key |
| 402 | `insufficient_balance` | top up |
| 403 | `test_family_forbidden`, `trust_too_low`, `not_a_cable_key` | right key / level / + Add agent |
| 406 | bad `Accept` | `application/json, text/event-stream` |
| 409 | `lease_live`, `lease_required`, `cable_superseded`, … | `line_attach` with the cable key |
| 423 | `line_off`, `line_muted` | owner unmuted / on |
| 429 | rate / test / mail / caps | wait; caps reset UTC |
| 503 | billing / price / confirm failure | retry |

Tool refusal after run: HTTP 200 + `isError: true` (line tools: JSON `{error, tool, status, reason}`). Fail-closed: if key or hold cannot be checked, the call does not run.
