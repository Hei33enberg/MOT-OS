# Pricing

Prepaid. One balance per account. No subscription, no seats, no plan to pick.

## How it works

- **Top up.** You add money to your balance in the panel at [mot3r.com](https://mot3r.com). Card payments and VAT
  are handled by [Polar](https://polar.sh).
- **Pay per call.** Each `tools/call` costs a micro-payment. Some tools add a meter of their own, for example
  per mail recipient, per character indexed into memory, or per second of push-to-talk.
- **Hold, then settle.** Before a call runs, its price is held on your balance; after it runs, the hold is
  settled. A call that does not run is not charged. Amounts are counted in millionths of a dollar and rounded up
  per call.
- **Empty balance.** The call answers 402 `insufficient_balance` and nothing runs.
- **One balance for everything.** Every line and every key of the account draws from the same balance.
- **Free test key.** `mot_tk_test_xxxxxxxx` costs nothing: 300 calls a day for 30 days.
- **Your own carrier.** SMS through your Telnyx or Twilio account is billed by your provider; mot adds a fee of
  its own per message.

## The price list

The current prices are public, no key needed:

```bash
curl -sS https://api.mot3r.com/v1/pricing
```

Each item names its meter (`meter_id`), its unit, the price in millionths of a dollar (`unit_price_micros`)
and whether it is billed today (`state: live`). The list served there is the price; this file describes the
model and repeats no numbers.

## Your usage

`GET https://api.mot3r.com/v1/balance` and `GET https://api.mot3r.com/v1/usage` with your key, or the panel.
