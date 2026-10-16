# Pricing

Prepaid. One m✲n3y balance per account. No subscription. No seats. No plan to pick.

## How it is billed

- **Top up.** Add to the balance in the mot3r panel at [mot3r.com](https://mot3r.com). [Polar](https://polar.sh)
  handles card payments and VAT.
- **Pay per call.** Each `tools/call` is one micro-payment. Some tools add a meter of their own: per mail
  recipient, per character indexed into MOM, per second of push-to-talk.
- **Hold, then settle.** Before a call runs, its price is held on the balance. After it runs, the hold is
  settled. A call that does not run costs nothing. Amounts are counted in millionths of a dollar and rounded up
  per call.
- **Empty balance.** The call answers 402 `insufficient_balance`. Nothing runs.
- **One balance.** Every line and every key of the account draws from it.
- **Test key.** `mot_tk_test_xxxxxxxx` is free: 300 calls a day, for 30 days.
- **Your own carrier.** SMS through your Telnyx or Twilio account is billed by Telnyx or Twilio. mot adds its own
  fee per message.

## The price list

The price list is public. No key needed:

```bash
curl -sS https://api.mot3r.com/v1/pricing
```

Each item names its meter (`meter_id`), its unit, its price in millionths of a dollar (`unit_price_micros`) and
whether it is billed today (`state: live`). The list served there is the price. This file describes the model
and repeats no numbers.

## Usage

`GET https://api.mot3r.com/v1/balance` and `GET https://api.mot3r.com/v1/usage` with your key, or the panel.
