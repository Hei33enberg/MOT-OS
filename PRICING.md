# Pricing

Prepaid balance (m✲n3y) in USD. No subscription. No seats. Live list: [api.mot3r.com/v1/pricing](https://api.mot3r.com/v1/pricing).

## How it works

1. **Starting credit** — new accounts get a credit shown at signup in the panel (and on the registration screen).
2. **Top up** — from 10 USD (10 / 25 / 50 / 100) at [mot3r.com/panel](https://mot3r.com/panel/). Confirm email first. Cards via [Polar](https://polar.sh) (VAT handled there). First paid top-up opens account level Z0 ([limits](./docs/limits.md#account-levels)).
3. **Pay per call** — each `tools/call` is metered (`mcp.tool_call`). Extra meters: mail recipients, MOM ingest/search, SMS via your carrier.
4. **Hold → settle** — price held before the call; settled after. Failed calls cost nothing. Amounts in micro-dollars, rounded up per call.
5. **Empty** — `402 insufficient_balance` with `available_micros` / `needed_micros`. Nothing runs.
6. **Test key** — free daily quota; see [limits](./docs/limits.md).
7. **Your SMS carrier** — Telnyx/Twilio bill the SMS; mot adds its fee.

## Live price list

```bash
curl -sS https://api.mot3r.com/v1/pricing
```

No key. Each row has `meter_id`, `unit_price_micros`, `per_units`, `state` (`live` = billed today).

## Balance and usage

With a line or root key:

- `GET https://api.mot3r.com/v1/balance`
- `GET https://api.mot3r.com/v1/usage?from=YYYY-MM-DD&to=YYYY-MM-DD` (`group_by`: `meter` \| `key` \| `line` \| `day`)

Also in the panel.
