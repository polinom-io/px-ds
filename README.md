# px-ds: Polinom.io Design System

One design system for two brands, **Polinom.io** and **TreatMint**, in light and dark mode, on the web (React, used from Astro) and Flutter, with native iOS and Android to follow.

> **Status: Phase 1, in build.** Nothing is published yet. This repository holds the design tokens, the build that turns them into platform files, the fonts, and the React components (`packages/web`, in build). Flutter widgets come next.

## What's here

```text
px-ds/
├── tokens/                  the only place tokens are edited
│   ├── tokens.json          colour, type, spacing, radius, shadow, sizing…
│   ├── motion.tokens.json   durations and easings (DTCG format)
│   └── contrast-pairs.json  colour pairs that must meet WCAG 2.2 AA
├── tools/                   token build: Node, no dependencies
├── packages/
│   ├── web/                 @polinom-io/px-ds-react: 14 React components, src/tokens/tokens.css (generated)
│   └── flutter/             px_ds: tokens as ThemeExtensions (lib/src/tokens/tokens.g.dart) and fonts (assets/fonts), generated
├── assets/fonts/            Atkinson Hyperlegible Next, Hack (woff2 + ttf) and their licences
└── assets/logos/            Polinom.io logo files (SVG + PNG); trademarks, not MIT
```

Planned next: Flutter widgets in `packages/flutter` (the package itself holds tokens and fonts today), an Astro playground and a Flutter gallery under `apps/`. iOS and Android come in Phase 2.

## Quick start

You need Node 26 (the version is pinned in `.nvmrc`; the build also runs on Node 22).

```sh
nvm use
node tools/build.mjs          # regenerate every platform file and run every check
node tools/build.mjs --check  # write nothing; fail if a generated file is out of date
```

The build runs these steps, and stops with a non-zero exit code if any required step fails:

| Step | Fails the build |
| --- | --- |
| Web CSS export → `packages/web/src/tokens/tokens.css` | Yes, on a missing theme value, a broken or circular alias, or a bad or duplicate name |
| Dart export → `packages/flutter/lib/src/tokens/tokens.g.dart` | Yes, also when two names become the same Dart identifier or a Dart reserved word |
| Verification of both outputs against `tokens.json` | Yes |
| Contrast check (`tokens/contrast-pairs.json`, 356 pairs over 4 themes) | Yes |
| Colour-blindness report on status and tone colours | No: every status and tone carries an icon, word or label, so colour alone never carries meaning |

## Changing tokens

1. Edit `tokens/tokens.json` or `tokens/motion.tokens.json`. Never edit a generated file: they say "do not edit" at the top, and CI rejects them when they don't match the tokens.
2. Run `node tools/build.mjs` and commit the regenerated files with your change.
3. Open a pull request. The core team reviews every token change.

**Names** are lowercase and hyphenated in the sources (`color-action-primary-bg`) and converted per platform:

| Platform | Semantic token | Primitive | Text role |
| --- | --- | --- | --- |
| CSS | `--color-action-primary-bg` | `--neutral-850` | `--text-heading-lg` |
| Dart | `PxDsColors.colorActionPrimaryBg` | `PxDsPrimitives.px.neutral850` | `PxDsTypography.textHeadingLg` |

Components use semantic tokens (`color-*`, text roles, `space-*`, `radius-*`, `shadow-*`) only, never primitives or raw values.

## Themes and modes

| Theme | Brand | Used by |
| --- | --- | --- |
| `px` | Polinom.io | www.polinom.io, iOS and Android reference apps |
| `treatmint` | TreatMint | TreatMint app (Flutter), treatmint.polinom.io |

Both have a light and a dark mode. Themes differ in colour only; spacing, radius, type and motion are shared.

### Web

Set the brand on `<html>`. Leave `data-mode` off and the page follows the visitor's system setting, with the right colours on the first paint and no JavaScript needed:

```html
<html data-theme="px">
```

Set `data-mode="light"` or `data-mode="dark"` only when the visitor picks a mode themselves, from a small inline script in `<head>` that reads their saved choice.

### Flutter

```dart
MaterialApp(
  theme: ThemeData(extensions: PxDsTheme.extensions(PxDsBrand.treatmint, Brightness.light)),
  darkTheme: ThemeData(brightness: Brightness.dark, extensions: PxDsTheme.extensions(PxDsBrand.treatmint, Brightness.dark)),
);

final colors = Theme.of(context).extension<PxDsColors>()!;
```

CI compiles and tests it on every pull request (Flutter 3.47.9). Install it as shown in [packages/flutter/README.md](packages/flutter/README.md).

## Packages (planned)

| Platform | Package | Installed from |
| --- | --- | --- |
| Web | `@polinom-io/px-ds-react` | GitHub Packages (npm) |
| Flutter | `px_ds` | a release tag of this repo |
| iOS (Phase 2) | `PxDS` | a release tag of this repo (Swift Package Manager) |
| Android (Phase 2) | `io.polinom:px-ds-compose` | GitHub Packages (Maven) |

All packages are public and released together under one version. A site that uses the web package adds the registry to its project `.npmrc`:

```ini
@polinom-io:registry=https://npm.pkg.github.com
```

GitHub Packages needs a token to install, even for public packages. It goes in each developer's `~/.npmrc` (`//npm.pkg.github.com/:_authToken=<token with read:packages>`) or comes from CI; pnpm 12 ignores credentials in a project's own `.npmrc`. See [packages/web/README.md](packages/web/README.md).

## Releasing

All packages share one version. To release the web package:

1. In a pull request, set `"version"` in `packages/web/package.json` (for example `0.2.0`) and merge it.
2. Tag that commit on `main` with the same version and push the tag:
   ```sh
   git checkout main && git pull
   git tag v0.2.0 && git push origin v0.2.0
   ```
3. The **Release** workflow checks that the tag matches the version and is on `main`, runs the token check, typecheck, tests and build, publishes `@polinom-io/px-ds-react` to GitHub Packages and creates a GitHub release with generated notes.

A tag with a hyphen (`v0.2.0-rc.1`) publishes under the `next` dist-tag and is marked as a pre-release, so `latest` only moves on real releases. Pull requests that touch the package run the same workflow as a dry run and list the package contents in the job summary.

## Accessibility

Every colour pair in `tokens/contrast-pairs.json` meets WCAG 2.2 AA in all four themes: 4.5:1 for text, 3:1 for control outlines, focus rings and other non-text parts. Colour never carries meaning alone. Every component must also work at 200% text scale and respect the reduced-motion setting on its platform; those checks arrive with the components.

## Fonts

| Family | Version | Used for | Licence |
| --- | --- | --- | --- |
| [Atkinson Hyperlegible Next](https://github.com/googlefonts/atkinson-hyperlegible-next) | 2.001 (variable, roman and italic) | All text except code | SIL Open Font License 1.1 |
| [Hack](https://github.com/source-foundry/Hack) | 3.003 (regular, bold) | Code and keyboard keys | MIT, with the Bitstream Vera licence |

The web uses the woff2 files; Flutter, iOS and Android use the ttf files. Both come from the same upstream releases, and the licences sit next to the files.

## Ownership

The core team (core@polinom.io) owns tokens, tools and the web package, and reviews every change to them. Mobile packages are shared with the platform leads. The full specification, with scope, decisions and the component inventory, is kept by the core team.

## Licence

[MIT](LICENSE), © 2026 Polinom.io. The fonts in `assets/fonts/` keep their own licences: SIL Open Font License 1.1 for Atkinson Hyperlegible Next, MIT with the Bitstream Vera licence for Hack. The logos in `assets/logos/` are trademarks of Polinom.io SpA and are not covered by the MIT licence.
