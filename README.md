# @datasage/ngx-card [![License: MIT](https://img.shields.io/badge/License-MIT-brightgreen.svg)](https://opensource.org/licenses/MIT) [![CI](https://github.com/datasage/ngx-card/actions/workflows/ci.yml/badge.svg)](https://github.com/datasage/ngx-card/actions/workflows/ci.yml)

Angular wrapper for [card.js](https://github.com/jessepollak/card).

> **Fork notice.** This is a maintained fork of [`ihym/ngx-card`](https://github.com/ihym/ngx-card) by Vasilis Diakomanolis (last upstream release 0.2.4, 2017). The fork modernizes the library for Angular 13+ and ships under a new package name on the GitHub Packages npm registry. All credit for the original design goes to the upstream author.

![card](http://i.imgur.com/qG3TenO.gif)

## Compatibility

Library major versions track the minimum supported Angular version:

| @datasage/ngx-card | Angular floor |
| ------------------ | ------------- |
| `1.x`              | 13            |
| `2.x`              | 14            |
| ...                | ...           |
| `N.x`              | `N + 12`      |

A single library major can span multiple Angular majors when no API change forces the floor up. Pick the major matching your Angular floor; the upper bound widens over patch releases as new Angular majors are verified.

## Installation

This package is published to **GitHub Packages**, not npmjs.com. Add the registry mapping to a project-local `.npmrc` (or your `~/.npmrc`):

```ini
@datasage:registry=https://npm.pkg.github.com
```

Then install:

```bash
npm install --save @datasage/ngx-card
```

GitHub Packages allows anonymous reads of public packages, so no `npm login` is required for installation.

`@datasage/ngx-card` does not bundle [card.js](https://github.com/jessepollak/card) — load it yourself, e.g.:

```html
<script src="https://unpkg.com/card@2.3.0/dist/card.js"></script>
```

## Usage

Import `CardModule` into the NgModule that declares the component using the directives:

```ts
import { CardModule } from '@datasage/ngx-card';

@NgModule({
  imports: [CardModule],
  declarations: [MyComponent],
})
export class MyModule {}
```

Then add the directives to your form. Both prefixed (`ngxCard*`) and the legacy unprefixed selectors are accepted — pick one style per template:

```html
<div class="card-container"></div>

<form
  ngxCard
  container=".card-container"
  card-width="500"
  [messages]="messages"
  [placeholders]="placeholders"
  [masks]="masks"
  [formatting]="false"
  [debug]="true"
>
  <input type="text" name="number"     ngxCardNumber />
  <input type="text" name="first-name" ngxCardName />
  <input type="text" name="last-name"  ngxCardName />
  <input type="text" name="expiry"     ngxCardExpiry />
  <input type="text" name="cvc"        ngxCardCvc />
</form>
```

You can use multiple inputs of the same kind (e.g. first/last name) — they will be merged into a single rendered field in card.js.

## API

### `[ngxCard]` / `[card]`

| Input          | Type                            | Default                                                   | Notes                                                |
| -------------- | ------------------------------- | --------------------------------------------------------- | ---------------------------------------------------- |
| `container`    | `string \| HTMLElement`         | —                                                         | Selector or DOM element where the card preview lives |
| `card-width`   | `number`                        | `350`                                                     | Pixel width of the rendered card                     |
| `messages`     | `Partial<NgxCardMessages>`      | `{ validDate: 'valid\\nthru', monthYear: 'month/year' }`  | Translation strings                                  |
| `placeholders` | `Partial<NgxCardPlaceholders>`  | dotted defaults                                           | Per-field placeholder text                           |
| `masks`        | `Record<string, unknown>`       | —                                                         | Forwarded to card.js                                 |
| `formatting`   | `boolean`                       | `true`                                                    | Forwarded to card.js                                 |
| `debug`        | `boolean`                       | `false`                                                   | Forwarded to card.js                                 |

### `[ngxCardNumber]` / `[card-number]`
### `[ngxCardName]` / `[card-name]`
### `[ngxCardExpiry]` / `[card-expiry]`
### `[ngxCardCvc]` / `[card-cvc]`

Marker directives that auto-assign a unique `name` attribute when one isn't provided.

## Development

```bash
npm install
npm run build      # ng build ngx-card --configuration production -> dist/ngx-card
npm run lint
npm test           # placeholder; tests not yet wired up
```

## Releases

Releases are cut via the **Cut Release** GitHub Actions workflow (manual dispatch). Choose `patch`, `minor`, or `major`; the workflow bumps `projects/ngx-card/package.json`, regenerates `CHANGELOG.md`, tags, pushes, publishes to GitHub Packages, and creates a GitHub Release. Publishing uses the auto-provided `GITHUB_TOKEN` — no separate npm secret is required. The workflow operates on whatever branch it's dispatched from, so maintenance releases for older majors run from their corresponding `*.x` branch.

## Credits

Original library: [`ihym/ngx-card`](https://github.com/ihym/ngx-card) by [Vasilis Diakomanolis](https://github.com/ihym). Underlying credit-card UI: [`card.js`](https://github.com/jessepollak/card) by Jesse Pollak.

## License

MIT — see [LICENSE](./LICENSE). Copyright (c) 2016 Vasilis Diakomanolis, (c) 2026 Dan Johansson.
