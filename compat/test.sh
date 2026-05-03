#!/usr/bin/env bash
# Scaffolds a minimal Angular app at the given major version, installs
# @datasage/ngx-card, replaces the default scaffold with an NgModule-based
# fixture that exercises CardModule, and runs a production build.
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

echo "::group::Replace fixture with NgModule consumer"
# Wipe whatever the scaffold generated (standalone-default since Angular 17+)
# and write a deterministic NgModule-based fixture that works on every major.
rm -rf src/app
mkdir -p src/app

cat > src/main.ts <<'EOF'
import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';
import { AppModule } from './app/app.module';

platformBrowserDynamic()
  .bootstrapModule(AppModule)
  .catch((err) => console.error(err));
EOF

cat > src/app/app.module.ts <<'EOF'
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { CardModule } from '@datasage/ngx-card';
import { AppComponent } from './app.component';

@NgModule({
  imports: [BrowserModule, CardModule],
  declarations: [AppComponent],
  bootstrap: [AppComponent],
})
export class AppModule {}
EOF

cat > src/app/app.component.ts <<'EOF'
import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
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
