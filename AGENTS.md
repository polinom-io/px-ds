<!-- Public repo: import public context only. Never add internal Polinom.io details here. -->
# px-ds

Polinom.io Design System: one set of design tokens for two brands (Polinom.io and TreatMint), light and dark, built into platform packages. See README.md for the full guide.

## Shared context
Polinom.io rules are synced into `.ai/` from px-context; edit them there. CLAUDE.md imports `.ai/global.md` and `.ai/engineering/engineering.md`. If your harness has not loaded them, read them before any task. Read the other `.ai/` files when their trigger applies:
- `.ai/project-overview.md` (repo-owned): before planning, scoping or explaining work in this repo.
- `.ai/business-rules.md` (repo-owned): before changing tokens, components, the token build or contrast pairs.
- `.ai/engineering/tech-stacks/tech-stacks.md`, then `node-typescript.md`, `web.md` and `flutter.md`: before writing or reviewing code.
- `.ai/company-public.md`: before describing Polinom.io publicly.

<!-- Synced .ai/ files come from polinom-io/px-context; edit them there. project-overview.md and business-rules.md belong to this repo. -->

## Layout
- `tokens/` — the only place tokens are edited (`tokens.json`, `motion.tokens.json`, `contrast-pairs.json`)
- `tools/` — token build, Node with no dependencies
- `packages/web/` — `@polinom-io/px-ds-react`, React components; `src/tokens/tokens.css` is generated
- `packages/flutter/` — `px_ds`; `lib/src/tokens/tokens.g.dart` is generated
- `assets/fonts/` — Atkinson Hyperlegible Next and Hack, with licences
- `assets/logos/` — official logo files; trademarks, not MIT. Never edit, redraw or strip their metadata
- `docs/spec.md` — design system spec (scope, theming, inventory, a11y, governance); `docs/specs/<name>.md` — one spec per component. All specs live here and change by pull request.

## Commands
- Node: version in `.nvmrc` (`nvm use`); package manager pnpm
- Tokens: `node tools/build.mjs` (regenerate + all checks), `node tools/build.mjs --check` (fail if generated files are stale)
- Web: `pnpm install --frozen-lockfile`, then `pnpm --filter @polinom-io/px-ds-react typecheck|test|build`
- Flutter (in `packages/flutter`, SDK pinned in `.fvmrc`): `fvm install`, then `fvm flutter pub get`, `fvm flutter analyze`, `fvm flutter test --exclude-tags gallery`

## Rules
- Never edit generated files (`tokens.css`, `tokens.g.dart`). Change `tokens/*.json`, run the build, commit both.
- Components use semantic tokens only (`color-*`, text roles, `space-*`, `radius-*`, `shadow-*`), never primitives or raw values.
- Every colour pair a component uses must be in `tokens/contrast-pairs.json` and pass WCAG 2.2 AA in all 4 themes.
- Never convey meaning with colour alone: status and tone always carry an icon, word or label.
- Token changes need core-team review. Releases are made by release-please: merge its release PR. Never bump versions, edit `CHANGELOG.md`, push tags or publish by hand.
- This repo is public: no internal accounts, people, infrastructure or customer data in code, issues, PRs or commits.
