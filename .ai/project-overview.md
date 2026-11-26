# px-ds: project overview

## What it is

px-ds is the Polinom.io Design System: one shared set of design decisions (colours, type, spacing, motion) and UI components, so every Polinom.io product looks and behaves the same without each team rebuilding buttons and forms.

It serves two brands, **Polinom.io** and **TreatMint**, each in light and dark mode (4 themes). A product picks a brand and a mode; the components stay the same.

## How it works

1. **Tokens are the source.** Every design decision lives as a named token in `tokens/*.json` (for example `color-action-primary-bg`). Nothing else is edited by hand.
2. **A build turns tokens into platform files.** `node tools/build.mjs` generates CSS for the web and Dart for Flutter, then checks that both match the tokens and that every colour pair passes WCAG 2.2 AA contrast in all 4 themes.
3. **Components use only semantic tokens.** React components (`packages/web`) and, next, Flutter widgets (`packages/flutter`) read tokens, never raw values, so changing a token changes every product at once.
4. **Products install the packages.** Web: `@polinom-io/px-ds-react` from GitHub Packages, used from Astro. Mobile: the `px_ds` Flutter package.

## Who uses it

1. Product teams building Polinom.io and TreatMint web and mobile apps, and the Polinom.io landing page.
2. Designers, who use the same tokens and component specs (`docs/specs/`) as the code.

## Where it stands

1. **Phase 1 (now):** tokens, fonts and 14 React components are built and released (latest release in GitHub Releases). Flutter has tokens and fonts; widgets come next.
2. **Phase 2:** native iOS (SwiftUI) and Android (Compose) versions of components already stable on web and Flutter.
3. **Phase 3:** data visualization (charts).

## Key rules

1. Accessibility is a requirement: WCAG 2.2 AA contrast, and meaning is never shown with colour alone.
2. Token changes need core-team review.
3. Releases are automated with release-please; nobody publishes by hand.
4. The repo is public: no internal or customer information.

Full detail: `README.md` and `docs/spec.md`.
