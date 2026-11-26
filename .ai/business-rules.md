# px-ds: business rules

Domain rules the code must keep. Repo-owned (not synced from px-context). Each rule says where it is enforced.

## Tokens

1. `tokens/*.json` is the only source of design values. Generated files (`packages/web/src/tokens/tokens.css`, `packages/flutter/lib/src/tokens/tokens.g.dart`) are never edited by hand; change the tokens, run `node tools/build.mjs`, commit both. Enforced: `node tools/build.mjs --check` in CI.
2. Every semantic token has a value in all 4 themes (Polinom.io and TreatMint, light and dark). Enforced: the build fails on a missing theme value.
3. Token names are lowercase and hyphenated in the sources, unique, and map to a valid, unique identifier on every platform. Enforced: the build.
4. Token changes need core-team review. Enforced: CODEOWNERS.

## Components

1. Components use semantic tokens only (`color-*`, text roles, `space-*`, `radius-*`, `shadow-*`), never primitives or raw values.
2. A component's behaviour and API are the same in every theme; a brand or mode changes only token values.
3. Every component has a spec in `docs/specs/<name>.md` before it is built, and its status in `docs/spec.md` §5 is kept current.
4. Web (React) is the reference implementation for behaviour and accessibility; Flutter matches it. Native iOS and Android only implement components already stable on web and Flutter.

## Accessibility

1. Every colour pair a component uses is listed in `tokens/contrast-pairs.json` and passes WCAG 2.2 AA in all 4 themes. Enforced: the build's contrast check.
2. Meaning is never conveyed by colour alone: status and tone always carry an icon, word or label.

## Brand assets

1. Logo files in `assets/logos/` are trademarks, not MIT: never edit, redraw or strip their metadata.
2. Fonts in `assets/fonts/` ship with their licences.

## Releases

1. Versions, `CHANGELOG.md`, tags and publishing are owned by release-please; never by hand.
