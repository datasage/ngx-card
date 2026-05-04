# Roadmap & version-change strategy

This document captures the strategic plan for when and why `@datasage/ngx-card` should cut new major versions. It exists so any contributor — human or AI agent — can pick up the long-term direction without reconstructing it from chat history.

Companion documents:

- [`README.md`](./README.md) — versioning policy summary table and consumer-facing usage.
- [`CHANGELOG.md`](./CHANGELOG.md) — what shipped per release.
- [`.github/workflows/compat.yml`](./.github/workflows/compat.yml) + [`compat/test.sh`](./compat/test.sh) — automated build-time compat against released Angular majors.

## Versioning policy (recap)

Library major version maps to the **minimum supported Angular major**:

| Library major | Angular floor |
| ------------- | ------------- |
| `1.x`         | 13            |
| `2.x`         | 14            |
| ...           | ...           |
| `N.x`         | `N + 12`      |

A single library major can — and should — span multiple Angular versions when it remains compatible. **Bump major only when the floor actually rises** (i.e., we adopt an API not present in the current floor). New Angular major releases are NOT in themselves a reason to cut a new library major: widen the peer dep upper bound on the existing major and ship a patch.

## Default posture

**Stay on 1.x indefinitely.** Widen `peerDependencies` as the compat matrix proves new Angular majors work. Cut a new library major only in response to concrete demand for a feature that requires raising the floor. Premature majors fragment the user base.

The right trigger is *"a real consumer wants feature X and that forces Angular ≥ Y"* — not *"Angular Y came out and has a cool feature."*

## What would force a floor bump

Adoption ladder, ordered by likely impact for this specific library:

| Adopt | Requires Angular ≥ | Library bump | Impact |
| ----- | ----------------- | ------------ | ------ |
| **Standalone directives** (drop `CardModule`, consumers import directives directly via `imports: [NgxCard, ...]`) | 14.1 | **2.x** | **High.** Modern Angular consumers expect this. The single most consumer-visible improvement. |
| **`inject()` for DI** (replace constructor injection inside directives) | 14 | 2.x (folds in) | Low-medium. Internal cleanup, smaller `.d.ts`, no consumer-visible API change. |
| **Typed reactive forms** | 14 | n/a | None — we expose no forms API. |
| **`NgOptimizedImage`** | 15 | n/a | None. |
| **Signals** (replace `_messages` / `_placeholders` setter+getter pairs with `signal()`) | 16 | **4.x** | Low-medium. Internal nicety; consumer API unchanged. |
| **`DestroyRef`** (replace `OnDestroy` + the `destroyed` flag with `inject(DestroyRef).onDestroy(...)`) | 16 | 4.x (folds in) | Medium. Kills the awkward `destroyed` boolean used to handle the dynamic-import race in `card.directive.ts`. |
| **Required inputs** (`@Input({ required: true })`) | 16 | n/a | None — we have no required inputs. |
| **Input signals** (`input<T>()` / `input.required<T>()`) | 17.1 stable | **5.x** | Medium. Slightly cleaner input declarations. |
| **New control flow** (`@if` / `@for` / `@defer`) | 17 | n/a | None — this is a 5-attribute-directive library with zero templates. |
| **Zoneless support** | 18 preview / 20 stable | **6.x** or **8.x** | Low. The directive itself is zone-agnostic; the dynamic `import('card')` callback may need a `runInInjectionContext` wrapper for zoneless-safety. |
| **`afterRenderEffect` / reactive effects** | 17 / 19 | 5.x / 7.x | None — directive is one-shot in `ngAfterViewInit`. |

## Non-Angular triggers

| Trigger | Library bump |
| ------- | ------------ |
| **TypeScript major required by adopted Angular** (e.g., TS 5.0+ for Angular 16) | Folds in with the Angular bump that requires it. |
| **Replace card.js with a native Angular implementation** | Major bump regardless of Angular floor. See "Future direction" below. |
| **Drop `CardModule` export** after a standalone migration deprecation window | Major bump on its own (removing a public export is semver-major). |
| **Drop legacy `[card]` / `[card-number]` selector aliases** | Major bump on its own. |
| **ng-packagr APF version change producing incompatible output** | Usually transparent; rarely forces a major. |

## Recommended sequencing if we ever do cut new majors

The highest-impact-per-effort progression:

### 1. `2.x` — Angular 14.1+ floor, standalone migration

Single most consumer-visible improvement. Sketch:

- Convert each `@Directive` to `standalone: true`.
- Replace constructor DI with `inject(ElementRef)` etc.
- Keep `CardModule` as a thin deprecation shim that re-exports the standalone directives (drop in 3.x).
- Reconsider the `import './card.types'` side-effect file once `inject()` lets us move the `globalThis.global` polyfill into a provider/`APP_INITIALIZER`.
- Update README install snippet to use `imports: [NgxCard, NgxCardNumberTemplate, ...]` directly in standalone consumer components.

Estimated effort: ~half a day.

### 2. `3.x` or `4.x` — Angular 16+ floor, signals + DestroyRef

Internal modernization. Most visible win is replacing the awkward `destroyed` flag (used to no-op the dynamic-import callback if the directive tore down before card.js resolved) with:

```ts
const destroyRef = inject(DestroyRef);
const sub = import('card').then(...);
destroyRef.onDestroy(() => { /* cancel/dispose */ });
```

`_messages` / `_placeholders` setter+getter pairs collapse into a single `signal()`-backed property with a custom merge update.

### 3. `5.x` — Angular 17+ floor, input signals

`@Input() container` → `container = input<string | HTMLElement>()`. Cleaner types, slightly different consumer ergonomics for binding (`[container]` still works the same). Can fold into `4.x` if timing aligns and we don't mind a single larger jump.

### 4. `6.x` or beyond — zoneless support

Verify the `import('card').then(...)` callback behaves correctly outside a Zone. Likely needs `runInInjectionContext` so `inject()`-based wiring still works. Otherwise mostly a verification exercise.

## Future direction (not part of the major-bump ladder)

Two paths are on the table for "after we've squeezed all the value out of being a thin card.js wrapper" — see also `MEMORY.md` → "ngx-card long-term goals":

1. **Native re-implementation.** Build the credit-card preview animation directly in Angular templates/components, eliminating the `card` npm dependency entirely. Removes:
   - The CommonJS-bailout warning.
   - The `globalThis.global` polyfill.
   - The dynamic-import workaround in `ngAfterViewInit`.
   - The hand-rolled `card.types.ts` ambient declaration.
   - The Angular 14-16 `card.css` `require` workaround.
   - The unmaintained-upstream risk.
2. **Repackage card.js.** Less ambitious — fork the upstream CoffeeScript source, rebuild as ESM with proper TypeScript types, ship as a separate package. Keeps the directive layer thin but removes most of the toolchain friction.

Either path is its own project, separate from version-bump work.

## Decision rule for "should we cut a major now?"

Run through this checklist:

1. **Is there a concrete consumer who needs feature X?** If no → defer.
2. **Does feature X require raising the Angular floor?** If no → just add the feature in a minor/patch on the current major.
3. **Is the floor bump worth fragmenting the support matrix?** If the answer feels marginal, defer.
4. **Is there an existing maintenance branch for the current major?** If no, cut `<currentMajor>.x` from `master` BEFORE merging the floor-raising commit, so existing-major users can still get back-ports.
5. Then bump.

Steps 4 is the easiest one to forget. The release workflow comments in [`.github/workflows/release.yml`](./.github/workflows/release.yml) reference this branching pattern.

## Updating this document

Touch this file when:

- A new Angular major releases and reshapes the adoption ladder (add a row, update minimum versions).
- We actually cut a new library major (record what triggered it, link to the release).
- A direction in "Future direction" gets started or scrapped.
- The default posture changes (e.g., we decide to track the latest Angular major aggressively instead of staying on 1.x).
