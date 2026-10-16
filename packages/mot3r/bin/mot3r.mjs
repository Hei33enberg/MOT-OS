#!/usr/bin/env node
// npm bin for mot3r: `mot3r install` == `node mot3r.mjs install`.
import { main } from '../mot3r.mjs';

main().catch((e) => {
  process.stderr.write(`mot3r: ${e.message}\n`);
  process.exitCode = 1;
});
