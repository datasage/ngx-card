# [0.0.0](https://github.com/datasage/ngx-card/compare/v1.0.2...v0.0.0) (2026-05-03)


### Bug Fixes

* **lib:** polyfill 'global' for card.js and load it via dynamic import ([2520805](https://github.com/datasage/ngx-card/commit/2520805d96873d7c2f75d97671cbd4d7795e104f))



# [0.0.0](https://github.com/datasage/ngx-card/compare/v1.0.1...v0.0.0) (2026-05-03)


### Bug Fixes

* **lib:** stop leaking project-relative path into published d.ts ([6269d1d](https://github.com/datasage/ngx-card/commit/6269d1dba85df8ca6b067fad5e24bb41b5d7948c))



# 0.0.0 (2026-05-03)


### Bug Fixes

* **app:** search for ContentChildren in descendants too ([1c78bd1](https://github.com/datasage/ngx-card/commit/1c78bd1d4a6718ff448db5e3dd9687fcd6e17132)), closes [#1](https://github.com/datasage/ngx-card/issues/1)
* **build:** make ng-packagr build green and lock toolchain ([38d6d2b](https://github.com/datasage/ngx-card/commit/38d6d2bd5e94d83e688b360d5bc0084ab0402412))
* **build:** regenerate package-lock.json after pinning @types/node ([41c7fbe](https://github.com/datasage/ngx-card/commit/41c7fbe2df209d423cb743e2ceabd27e63d84618))


### Features

* **app:** add card module ([9f42383](https://github.com/datasage/ngx-card/commit/9f423837e7af4e981a1388ebcf06b2913155923a))
* **app:** relax card dependency ([dbd839c](https://github.com/datasage/ngx-card/commit/dbd839cedaef516d9ad15a42d66264360deab396))
* **lib:** bundle card.js as a regular dependency ([78d14bf](https://github.com/datasage/ngx-card/commit/78d14bfa9fd864ae7a85fb2f80bed1c0a2f1950b))
* **lib:** modernize directives for Angular 13 with backward-compat selectors ([4141e16](https://github.com/datasage/ngx-card/commit/4141e1653bdc8eed582ffd7e49d2e71e3fbb3e91))



# Changelog

This file is regenerated automatically by `conventional-changelog` during the release workflow. Pre-1.0 history (Angular 2–4 era) is available in the git history.

## Unreleased

### BREAKING CHANGES

- Library now requires Angular 13 or newer. The 0.x line targeted Angular 2–4 and is no longer maintained.
- Build output is the Angular Package Format (FESM2020 + UMD + types) produced by `ng-packagr`. The old `bundles/ngx-card.umd.js` path no longer exists; consumers should import via `'ngx-card'` (not `'ngx-card/ngx-card'`).
- Source moved from `src/` to `projects/ngx-card/src/lib/`.

### Features

- Each directive now accepts both the prefixed (`ngxCard*`) and the legacy unprefixed (`card*`) selector. Existing markup keeps working.
- `NgxCard` disposes the underlying card.js instance in `ngOnDestroy`.
- Strict types on every `@Input`; `NgxCardMessages` and `NgxCardPlaceholders` interfaces exported.
- Field-template directives now share an abstract `NgxCardFieldTemplate` base, also exported for advanced consumers.

### Build

- Replaced gulp + custom webpack bundle with Angular CLI + ng-packagr.
- Replaced tslint with `@angular-eslint`.
- Replaced Travis CI (Node 6) with GitHub Actions (Node 16/18 matrix).
- Manual-dispatch `Cut Release` workflow handles version bump, changelog, build, tag, npm publish, and GitHub Release.
