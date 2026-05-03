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
