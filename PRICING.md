# Pricing

Prepaid. One balance per account, called m✲n3y and counted in US dollars. No subscription. No seats. No plan to
pick.

## How it is billed

- **Top up.** Add to the balance in the mot3r panel at [mot3r.com/panel](https://mot3r.com/panel/), from 10 USD:
  10, 25, 50 or 100 at a time (`GET https://api.mot3r.com/v1/topup/status`). Confirm your email first.
  [Polar](https://polar.sh) handles card payments and VAT. The first top-up raises the account to level Z0
  ([docs/limits.md](./docs/limits.md#account-levels)).
- **Pay per call.** Each `tools/call` is one micro-payment (`mcp.tool_call`). Some tools add a meter of their own:
  per mail recipient (`mail.recipient`, `mAYL_send`), per character indexed into MOM (`mrag.ingest_char`,
  `mRAG_ingest`), per memory query (`mrag.query`, `mRAG_search`) and per SMS (`sms_byoc.message`).
- **Hold, then settle.** Before a call runs, its price is held on the balance. After it runs, the hold is
  settled. A call that does not run costs nothing. Amounts are counted in millionths of a dollar and rounded up
  per call.
- **Empty balance.** The call answers 402 `insufficient_balance` with `available_micros` and `needed_micros`.
  Nothing runs.
- **One balance.** Every line and every key of the account draws from it.
- **Test key.** `mot_tk_test_xxxxxxxx` is free: 300 calls and 200 sends a day per account, valid 30 days after its
  last use.
- **Your own carrier.** SMS through your Telnyx or Twilio account is billed by Telnyx or Twilio. mot adds its own
  fee per message.

## The price list

The price list is public. No key needed:

```bash
curl -sS https://api.mot3r.com/v1/pricing
```

Each item names its meter (`meter_id`) and its unit (`meter_unit`). `unit_price_micros` is the price in millionths
of a dollar for `per_units` units: `unit_price_micros: 20` with `per_units: 1000` means 20 millionths of a dollar
per thousand units. `display_price_micros` per `display_per` is the same price in a readable unit. `state: live`
means it is billed today. The list also carries `min_topup_usd` and the `rounding` rule.

What the list says is what you pay. This file explains how billing works; the prices live in the list.

## Usage

Read your balance with `GET https://api.mot3r.com/v1/balance` and your usage with
`GET https://api.mot3r.com/v1/usage?from=2026-10-01&to=2026-10-21`, using a line key or the root key. Both dates
are UTC and both are required. `group_by` is `meter`, `key`, `line` or `day`. The panel shows both.
