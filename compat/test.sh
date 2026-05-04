#!/usr/bin/env bash
# Scaffolds a minimal Angular app at the given major version, installs
# @datasage/ngx-card, replaces the default scaffold with a standalone-
# component fixture that exercises CardModule, and runs a production
# build.
#
# Usage: bash compat/test.sh <angular-major>
# Example: bash compat/test.sh 17
#
# Build success = the published library is install-and-build compatible
# with that Angular major. Failure = floor needs to rise (cut new library
# major) OR a workaround is needed before widening the peer dep range.

set -euo pipefail

ANGULAR_MAJOR="${1:?usage: $0 <angular-major>}"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

cd "$TMPDIR"

echo "::group::Scaffold Angular $ANGULAR_MAJOR app"
npx --yes --package "@angular/cli@$ANGULAR_MAJOR" -- ng new compat-app \
  --defaults --skip-git --skip-install --routing=false --style=css
echo "::endgroup::"

cd compat-app

echo "::group::Pin @types/node to TS-compatible version"
# ng new resolves @types/node via a caret range that may pick a patch using
# TS 5.2+ syntax (Symbol.dispose etc). Older Angular majors (14-16) ship TS
# 4.7-5.0 and fail to PARSE those declarations even with skipLibCheck.
# Pin via npm overrides to a pre-Symbol.dispose patch.
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
pkg.overrides = Object.assign({}, pkg.overrides, { '@types/node': '18.16.0' });
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
"
echo "::endgroup::"

echo "::group::Install Angular deps"
npm install
echo "::endgroup::"

echo "::group::Install @datasage/ngx-card"
# Two-layer compat signal:
#   1. Does the library's peer dep range permit clean installation?
#      (informational -- if narrow, widen projects/ngx-card/package.json
#      peerDependencies once the build below is green.)
#   2. Does the code itself compile and build in this Angular version?
# We use --legacy-peer-deps to bypass (1) so we can still test (2) when
# the peer dep range is too narrow.
if npm install @datasage/ngx-card --dry-run >/dev/null 2>&1; then
  echo "::notice title=Peer dep OK::Library installs cleanly on Angular $ANGULAR_MAJOR; peer dep range already permits this version."
else
  echo "::warning title=Peer dep narrow::Clean install on Angular $ANGULAR_MAJOR is blocked by peer dep range. If the build below is green, widen projects/ngx-card/package.json peerDependencies and ship a patch release."
fi

npm install @datasage/ngx-card --legacy-peer-deps
echo "::endgroup::"

echo "::group::Move card.js's CSS require out of webpack's way"
# card@2.5.x's lib/card.js has `require('./card.css');` at module top
# level for runtime style injection. Webpack's browser builder (Angular
# 14-16) follows that require and chokes on the bare CSS file. Even with
# the file registered in angular.json#styles, webpack STILL follows the
# require from card.js's module body and tries to parse the .css as JS.
#
# Workaround (also what consumers on Angular 14-16 need): copy the .css
# into src/, register it as a global style in angular.json, then strip
# the require() from the installed copy of card.js so webpack stops
# following it. Consumers can apply the same patch via patch-package.
# Angular 17+ esbuild handles the CSS require cleanly without this.
mkdir -p src/styles
cp node_modules/card/lib/card.css src/styles/card.css
node -e "
const fs = require('fs');
const config = JSON.parse(fs.readFileSync('angular.json', 'utf8'));
const cardCss = 'src/styles/card.css';
for (const projName of Object.keys(config.projects || {})) {
  const arch = (config.projects[projName].architect || {}).build;
  if (!arch) continue;
  for (const opts of [arch.options, ...(Object.values(arch.configurations || {}))]) {
    if (!opts) continue;
    opts.styles = opts.styles || [];
    if (!opts.styles.includes(cardCss)) opts.styles.push(cardCss);
  }
}
fs.writeFileSync('angular.json', JSON.stringify(config, null, 2));

// Strip the CSS require from card.js's installed copy so webpack stops
// following it. Idempotent: substitution does nothing if already applied.
const cardJs = 'node_modules/card/lib/card.js';
const src = fs.readFileSync(cardJs, 'utf8');
const patched = src.replace(/require\\(['\"]\\.\\/card\\.css['\"]\\);?/g, '/* css loaded via angular.json#styles */');
if (patched !== src) {
  fs.writeFileSync(cardJs, patched);
  console.log('Patched card.js to remove CSS require.');
}
"
echo "::endgroup::"

echo "::group::Replace fixture with standalone CardModule consumer"
# Standalone bootstrap works on Angular 14.1+ (which is every version we
# test). Avoids needing @angular/platform-browser-dynamic (dropped from
# ng new defaults in Angular 20+) and sidesteps the standalone-default
# behaviour change in Angular 19+.
rm -rf src/app
mkdir -p src/app

cat > src/main.ts <<'EOF'
import { bootstrapApplication } from '@angular/platform-browser';
import { AppComponent } from './app/app.component';

bootstrapApplication(AppComponent).catch((err) => console.error(err));
EOF

cat > src/app/app.component.ts <<'EOF'
import { Component } from '@angular/core';
import { CardModule } from '@datasage/ngx-card';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CardModule],
  template: `
    <div class="card-wrapper"></div>
    <form ngxCard container=".card-wrapper">
      <input name="number" ngxCardNumber />
      <input name="name" ngxCardName />
      <input name="expiry" ngxCardExpiry />
      <input name="cvc" ngxCardCvc />
    </form>
  `,
})
export class AppComponent {}
EOF
echo "::endgroup::"

echo "::group::Production build"
npx --no-install ng build --configuration production
echo "::endgroup::"

echo "::notice title=Compat OK::Angular $ANGULAR_MAJOR built successfully against @datasage/ngx-card"
