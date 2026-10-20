# Python

Standard library only (`urllib`), Python 3.8 or newer.

```bash
python main.py                                   # connect and list tools
MOT_KEY="mot_lk_live_xxxxxxxx" python main.py    # also line_attach + line_inbox
```

It runs `initialize` and `tools/list`. With a line key it also runs `line_attach` and `line_inbox` with
`pending: true`. With a test key it calls `comms_capabilities` instead, because a test key does not reach the line
tools.
