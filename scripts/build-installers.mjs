// Writes install/install.sh and install/install.ps1 with packages/mot3r/mot3r.mjs embedded verbatim.
// `node scripts/build-installers.mjs --check` exits 1 when the installers are out of date.
import { readFileSync, writeFileSync, existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const src = readFileSync(join(root, 'packages', 'mot3r', 'mot3r.mjs'), 'utf8').replace(/\r\n/g, '\n');
const version = /export const VERSION = '([^']+)'/.exec(src)[1];

const SH_END = 'MOT3R_MJS_END';
const PS_END = "'@";
if (src.split('\n').includes(SH_END)) throw new Error(`mot3r.mjs contains the heredoc delimiter ${SH_END}`);
if (src.split('\n').some((l) => l.startsWith(PS_END))) throw new Error('mot3r.mjs has a line starting with the here-string end');

export const sh = `#!/bin/sh
# mot installer ${version}. MIT License. Wires the mot gateway into every MCP client on this machine.
#   curl -fsSL <raw url of this file> | sh
#   curl -fsSL <raw url of this file> | sh -s -- --dry-run --host cursor,vscode
# Requires Node.js 18 or newer. Copies mot3r.mjs to ~/.mot (MOT_HOME) and runs \`mot3r install\`.
set -eu

if ! command -v node >/dev/null 2>&1; then
  echo "mot: Node.js 18 or newer is required (https://nodejs.org)." >&2
  exit 1
fi
major=$(node -p 'parseInt(process.versions.node)')
if [ "$major" -lt 18 ]; then
  echo "mot: Node.js 18 or newer is required, found $(node --version)." >&2
  exit 1
fi

dir="\${MOT_HOME:-$HOME/.mot}"
mkdir -p "$dir"
cat > "$dir/mot3r.mjs" <<'${SH_END}'
${src.replace(/\n$/, '')}
${SH_END}

node "$dir/mot3r.mjs" install "$@"
`;

export const ps1 = `# mot installer ${version}. MIT License. Wires the mot gateway into every MCP client on this machine.
#   irm <raw url of this file> | iex
# Requires Node.js 18 or newer. Copies mot3r.mjs to %USERPROFILE%\\.mot (MOT_HOME) and runs \`mot3r install\`.
$ErrorActionPreference = 'Stop'

$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) { Write-Error 'mot: Node.js 18 or newer is required (https://nodejs.org).'; return }
$major = [int](& node -p 'parseInt(process.versions.node)')
if ($major -lt 18) { Write-Error "mot: Node.js 18 or newer is required, found $(& node --version)."; return }

$dir = if ($env:MOT_HOME) { $env:MOT_HOME } else { Join-Path $env:USERPROFILE '.mot' }
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$file = Join-Path $dir 'mot3r.mjs'
$src = @'
${src.replace(/\n$/, '')}
'@
[System.IO.File]::WriteAllText($file, $src.Replace("\`r\`n", "\`n") + "\`n", (New-Object System.Text.UTF8Encoding $false))

& node $file install @args
`;

const out = { [join(root, 'install', 'install.sh')]: sh, [join(root, 'install', 'install.ps1')]: ps1 };
if (process.argv.includes('--check')) {
  const stale = Object.entries(out).filter(([f, t]) => !existsSync(f) || readFileSync(f, 'utf8').replace(/\r\n/g, '\n') !== t);
  for (const [f] of stale) console.error(`out of date: ${f}`);
  process.exitCode = stale.length ? 1 : 0;
} else {
  for (const [f, t] of Object.entries(out)) writeFileSync(f, t);
  console.log(`wrote install.sh and install.ps1 (mot3r ${version})`);
}
