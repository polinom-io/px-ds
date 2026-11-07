# Polinom.io Design System: specification and roadmap

> **Purpose:** Single source of truth for the scope, status and decisions of the Polinom.io Design System, the one system shared by Polinom.io and TreatMint: platforms and phases, theming rules, build approach, the component inventory, the accessibility baseline, governance and the decision log. It drives scoping, prioritization, build order, and design↔code parity.
>
> **Status:** Draft v0.56 · **Owner:** document owner, core team · **Last updated:** 2026-11-06
>
> **Renamed in v0.24** from `ui-component-inventory.md` ("UI Component Inventory"), since the document now covers far more than the inventory in §5.
>
> **Specs live in the repo (v0.56, 6 Nov 2026):** this file is `docs/spec.md` in `polinom-io/px-ds`, and component specs are `docs/specs/<name>.md`. Changes go through pull requests like code. Tokens are edited in `tokens/` (v0.45); the Polinom.io design system page (internal brand book) shows them and is not a source.

---

## 1. How to use this document

1. **Audit** existing products (§8) and log every UI pattern found, including duplicates.
2. **Consolidate** duplicates into one canonical component (§9).
3. **Classify** each component by category, level, and priority (§3–§5).
4. **Track** lifecycle status per platform as work progresses (§3).
5. **Spec** each component using the template in §7 before it moves to `In design`.

Rows in §5 are a starting baseline drawn from common product needs. Delete what you don't need; don't build components with zero confirmed usage.

---

## 2. Scope

| In scope | Out of scope (for now) |
|---|---|
| Reusable, product-agnostic UI components | One-off marketing/campaign layouts (reusable marketing sections are in scope, §5.10) |
| Design tokens consumed by those components | Product-specific business logic |
| Composite patterns used in ≥ 2 products | Email templates (separate track) |
| Platforms: see §2.1 | Data visualization (charts): deferred to Phase 3 (§2.1) |

### 2.1 Target platforms

| Platform | Stack | Package / library | Phase | Notes |
|---|---|---|---|---|
| **Web** | React (TypeScript), consumed in Astro (§2.3) | `@polinom-io/px-ds-react` (GitHub Packages) | **Phase 1 (v1.0)** | Reference implementation for behavior and a11y |
| **Mobile (cross-platform)** | Dart / Flutter | _e.g. `org_ds_flutter`_ | **Phase 1 (v1.0)** | Theme via `ThemeData` / `ThemeExtension` generated from tokens |
| **iOS native** | Swift / SwiftUI (UIKit where needed) | _e.g. `OrgDesignSystem` (SPM)_ | Phase 2 | Follow platform conventions (HIG) where they conflict with web |
| **Android native** | Kotlin / Jetpack Compose | _e.g. `org-ds-compose`_ | Phase 2 | Follow platform conventions (Material) where they conflict with web |

**Phase 1** delivers tokens and components for Web (React) and Flutter. **Phase 2** adds iOS and Android native implementations of components already `Stable` in Phase 1; no new components are introduced native-first. **Phase 2 starts when every Phase 1 P0 component is `Stable` on Web and Flutter** (§10 parity rule); a P1 component that becomes `Stable` later joins the native backlog then. **Phase 3** adds data visualization (charts) across platforms, built on third-party charting libraries (§2.3).

**Phase 3 — Data visualization (scope outline)**
- The design system owns: chart color tokens (categorical, sequential, diverging) defined per theme × mode (§2.2) and validated for contrast and color-vision deficiency; chart styling rules (axes, gridlines, labels, legends, tooltips) expressed with system type and color tokens; accessibility rules (text alternative, data-table fallback, no color-only encoding).
- Charting libraries are wrapped behind system components so products never style the library directly; swapping a library later should not change product code. Charts are the one exception to the no-library rule (§2.3) and may appear before Phase 3 under interim rules.
- Library selection per platform is a Phase 3 decision (§12).
- Phase 1–2 prerequisite: keep the semantic color layer extensible so chart palettes can be added as new token groups without renaming existing tokens.

To keep Phase 2 cheap, Phase 1 must still:
- Export tokens to Swift and Kotlin from day one (no extra design work, and it validates the token pipeline early).
- Write specs (§7) in platform-neutral terms: anatomy, states, behavior, a11y; not React or Flutter specifics.
- Note any Flutter decision that would not map to SwiftUI/Compose idioms in the spec's *Notes / deviations* column.

**Flutter after Phase 2:** Flutter stays supported alongside iOS and Android native, because some products keep using it. From Phase 2 on, every mobile component has three implementations (Flutter, SwiftUI, Compose). To keep them consistent:
- The spec (§7) is the single source of truth; implementations follow it, not each other.
- One shared set of visual-regression reference screenshots per component state, checked against all three mobile implementations.
- A change to a component lands on all in-scope platforms in the same release, or is tracked as parity debt with a target date.
- Components only a native-platform product needs are proposed through governance (§10) like any other; they are not added to Flutter by default unless a Flutter product needs them.

**Long-term stance:** mobile will **not** converge on a single stack; Flutter, iOS native and Android native are permanent, separate implementations. Consequences:
- Cross-platform parity tooling is a lasting investment, not a stopgap: automated token export to Dart/Swift/Kotlin, a parity matrix generated from the platform-status tables in each spec, and shared visual-regression references.
- Mobile is owned by a **shared mobile team** covering Flutter, iOS native and Android native. To keep one platform from silently lagging:
  - Name a **platform lead** inside the team for each of Flutter, iOS and Android, accountable for that platform's quality, idioms and parity debt (a role, not a separate team).
  - Component work is planned as a unit: a mobile component ticket is "done" only when all in-scope mobile platforms for that component are done, or the gap is logged as parity debt.
  - Review parity debt at every release; any item older than two releases is escalated at the governance review (§10).
- Parity is scoped by consumer, not absolute: native implementations track what the `px-refimpl` demo apps need, Flutter tracks TreatMint (see the product → platform mapping).

#### Product → platform mapping

Each component's platform scope should reflect real consumers. A platform with no consuming product for a component can be marked `Won't do`.

Legend: ✅ uses · — does not use · ? unconfirmed

| Product | Type | Web (React) | Flutter | iOS native | Android native | Phase | Notes |
|---|---|---|---|---|---|---|---|
| **TreatMint** (app) | Product | — | ✅ | — | — | 1 | Primary Flutter consumer |
| **TreatMint product page** (`treatmint.polinom.io`) | Marketing / product site | ✅ | — | — | — | 1 | Product-specific web page |
| **Polinom.io landing page** (`px-landing-page`, `www.polinom.io`) | Marketing site | ✅ | — | — | — | 1 | Company landing page |
| **Polinom.io — `px-refimpl-ios`** | Native demo / reference app | — | — | ✅ | — | 2 | iOS reference implementation |
| **Polinom.io — `px-refimpl-android`** | Native demo / reference app | — | — | — | ✅ | 2 | Android reference implementation |

**Implications:**
- Flutter scope is driven by TreatMint's needs: Flutter components not used by TreatMint can be deferred.
- Web (React) consumers are both marketing sites, not applications. Phase 1 Web scope therefore centers on foundations, layout, content, navigation (header/footer), buttons/links, cards, accordion, simple forms (contact/signup), and the marketing sections in §5.10. App-heavy components (Data table, Date/Time picker, Combobox, Tree view, Command palette, Side navigation) can be deferred on Web until an app consumer exists.
- TreatMint has its own color palette, distinct from Polinom.io. Both are delivered through the theme layer (§2.2); components are shared, only theme values differ.
- Native (Phase 2) consumers are demo/reference apps, not production products. Native components should cover what the demos showcase; full parity with Flutter is not required unless a production native product is added.

### 2.2 Theming

The system is **multi-brand**. Components never reference raw colors; they consume semantic tokens whose values are supplied by a theme.

**Token tiers**

| Tier | Purpose | Example | Varies by theme? |
|---|---|---|---|
| **Primitive** (global) | Raw palette and scales; colour slots are shared by both brands | `neutral-900`, `brand-primary`, `accent-primary-light`, `space-4` | Palette: yes (each brand fills the same slots). Scales: shared |
| **Semantic** (alias) | Role-based names used by components | `color-action-primary-bg`, `color-text-default`, `color-border-subtle` | Yes: each theme maps roles to its primitives |
| **Component** (optional) | Per-component overrides where a role isn't specific enough | `button-primary-bg` → `color-action-primary-bg` | Rarely; only via semantic tokens |

**Themes**

| Theme | Applies to | Platforms |
|---|---|---|
| **Polinom.io** (base) | Polinom.io landing page (`px-landing-page`), `px-refimpl-ios`, `px-refimpl-android` | Web, iOS native, Android native |
| **TreatMint** | TreatMint app, TreatMint product page (`treatmint.polinom.io`) | Flutter, Web |

**Palettes (v0.28, 5 Nov 2026, rebuilt from scratch; brand primary set to violet in v0.29):** both brands fill the **same primitive slots**, in four categories; only the values differ per brand, and a brand with no distinct value for a slot aliases another slot. TreatMint keeps its v0.26 values, except accents: v0.31 gives it its own tertiary (gold) and quaternary (orchid).
- **Neutrals** (`neutral-0`, `-50`, `-100`, `-400`, `-600`, `-800`, `-850`, `-900`, `-950`): surfaces, text and lines. Polinom.io: a cool ramp built from the logo's ground #002B36 (= `neutral-900`, the dark page) and tile (`neutral-850` #0F3742); light page #F1F8FA, cards #FBFEFF. TreatMint: white, Mist pale, Line, Sage, Slate, Night line, Night raised, Night.
- **Brand** (`brand-primary`, `-secondary`, `-tertiary`, `-deep`, `-tint`, `-primary-fill-light`, `-primary-fill-dark`): exact identity colours, never text. Polinom.io: violet #6C71C4, orange #CB4B16, cyan #2AA198, the logo's three dots; violet shades #5E59BB / #9494FC fill the primary button and carry links and the focus ring (exact violet takes no label at 4.5:1). Blue and orange were tested as primary in v0.29 and rejected: blue sits in the info family, and orange matches the dark-mode danger button (ΔE00 7.9). TreatMint: Deep mint, Lavender, Teal, Mist; `brand-tertiary` = Lavender; fills = Teal / Deep mint.
- **Accents** (`accent-primary|secondary|tertiary|quaternary-light|dark`): emphasis tones for `tone` (Card, Badge, Avatar, Progress), text-safe on every surface. Polinom.io: magenta #BF1D71 / #FF6AAF, blue #0069AD / #46A6EF, teal #00716F / #3EAFAB, clay #462C26 / #B7988F. TreatMint: Deep mint #00745E / #00B694, Lavender #6353B0 / #A99BE0, gold #726418 / #CFB52B, orchid #B03B7D / #D685B3 (v0.31; gold and orchid shades keep the hue and move in lightness to pass 4.5:1: the brand gold #CFB52B is the dark value as is).
- **Status** (`status-success|warning|danger|info-light|dark`). Polinom.io, new: success #004610 / #80EEB6, warning #8B5E00 / #FFE374, danger #9D263D / #FF705F, info #004987 / #95ECFF, set at different lightness so success and danger separate for colour-blind users (§6.1). TreatMint: cyan, amber, red, blue; v0.32 moves the light values of warning (#9E5600) and danger (#7E1911) apart in lightness (dark values unchanged). v0.32 also darkens Polinom.io light success and danger for the same reason.

Polinom.io has 30 distinct colour values and TreatMint 24. All four theme × mode combinations pass AA for every text and control pair (380 pairs checked by script, 5 Nov 2026). Yellow and green were rejected as accents: they matched warning and success (ΔE00 0.5–2.2 under protan/deutan).

**Token naming (v0.30):** one source of names, converted to each platform's own convention by the token build.
- **Source and docs:** the hyphenated names in `tokens.json` are canonical, and this document uses them as written: `color-action-primary-bg`, `neutral-850`, `space-4`. Type roles are named by their style (`heading-lg`), font families by role (`font-brand`).
- **Exports:**

  | Platform | Form | `color-action-primary-bg` | `neutral-850` (primitive) | `heading-lg` (type role) |
  |---|---|---|---|---|
  | CSS | custom property | `--color-action-primary-bg` | `--neutral-850` | `--text-heading-lg` |
  | Dart (Flutter) | lowerCamelCase on a `ThemeExtension` | `colorActionPrimaryBg` | `PxDsPrimitives.px.neutral850` (primitives differ per brand) | `textHeadingLg` |
  | Swift | lowerCamelCase on the theme struct | `colorActionPrimaryBg` | `PxDsPrimitives.px.neutral850` | `textHeadingLg` |
  | Kotlin (Compose) | lowerCamelCase on the `CompositionLocal` theme | `colorActionPrimaryBg` | `PxDsPrimitives.px.neutral850` | `textHeadingLg` |

- **Rules the token build enforces:**
  - Semantic tokens export **flat** (`colorActionPrimaryBg`), never as nested objects, so a rename touches one identifier and a search finds it.
  - Primitives export in their own namespace (`PxDsPrimitives`), apart from semantic tokens, so lint can flag a component that skips the theme (§2.2 tiers).
  - Type roles export with the `text` prefix and families with `font` (`--text-heading-lg`, `textHeadingLg`, `--font-brand`), since type style names are not unique across families.
  - A digit stays attached to the word before it: `neutral-850` → `neutral850`, `space-4` → `space4`.
  - Two source names that convert to the same identifier, or a name that becomes a reserved word in Dart, Swift or Kotlin, fail the build; the source token is renamed, never escaped per platform.
  - **Brand name (v0.38):** in prose the brand is always **Polinom.io**, never "Polinom". Where a name cannot contain `.` (identifiers, package, repo and file names, theme ids), the short form is **`px`**, as in `px-landing-page`. **Packages (v0.40):** everything is published from the GitHub organisation `polinom-io` (repo `polinom-io/px-ds`, confirmed 5 Nov 2026, v0.44). npm packages go to GitHub Packages, whose scope must equal the organisation, so they are `@polinom-io/…` (`@polinom-io/px-ds-react`); this replaces the `@polinom.io` npm scope of v0.39. Android goes to GitHub Packages (Maven, group `io.polinom`). Flutter and SwiftPM install from the repo's git tags, because GitHub Packages has no Dart or Swift registry. **All packages are public (decided 5 Nov 2026, v0.41)**, hosted in the existing `polinom-io` organisation; installing from GitHub Packages' npm registry still needs a token with `read:packages`. **Package names (v0.42):** one stem, `px-ds`, in each registry's style: `@polinom-io/px-ds-react` (npm), `px_ds` (pub), `PxDS` (SwiftPM), `io.polinom:px-ds-compose` (Maven, Kotlin package `io.polinom.pxds`). A framework suffix (`-react`, `-compose`) only where the registry serves several frameworks. Generated files carry no prefix (`tokens.css`, `tokens.g.dart`). Dart, Swift and Kotlin types are prefixed `PxDs` (`PxDsColors`, `PxDsPrimitives`, `PxDsTypography`, `PxDsElevation`, `PxDsTokens`, `PxDsTheme`, `PxDsBrand`); React components are unprefixed. Theme ids are `px-light|dark` and `treatmint-light|dark` (renamed from `polinom-…` in v0.43): `data-theme="px"`, `PxDsBrand.px`, `PxDsColors.pxLight`. Remaining older `polinom` names (logo file names, the design system page's `window.Polinom` bundle namespace) are tracked in §12.
  - Theme and mode live in the theme object (`[data-theme]` and `[data-mode]` on Web, `ThemeData`, the theme struct), never in a token name.
  - `motion.tokens.json` (DTCG, nested) is flattened to hyphenated names first (`motion-duration-fast`), then converted like every other token.

**Rules**
- Themes differ in **color only** for now. Spacing, radius, elevation and motion are shared unless a documented need arises; add them to the theme layer only by explicit decision.
- **Typography is shared initially but theme-ready.** TreatMint starts with the Polinom.io typography and may diverge in a later iteration. To make that a token change rather than a component change:
  - Components reference **semantic type tokens** only (e.g. `heading-lg`, `body-md`, `font-brand`, `font-body`), never font names or raw sizes.
  - Semantic type tokens live in the theme layer from day one; in Phase 1 the TreatMint theme simply aliases the Polinom.io values.
  - **Decision point:** whether TreatMint typography diverges is decided after the TreatMint initial prototype is finished. Until then, no TreatMint-specific type values are introduced.
  - Layouts must tolerate font metric changes (different x-height, width, line height): no fixed-height text containers, and visual regression covers both themes.
  - Font loading/licensing is per theme on each platform (web font files, Flutter `pubspec` assets, iOS/Android bundled fonts), so a TreatMint font swap does not ship Polinom.io fonts to TreatMint or vice versa.
- Semantic token names are identical across themes; a theme is complete only when it defines every semantic token (validated in the token build).
- Each theme **and mode** must independently pass contrast checks (§6); a component verified in one theme/mode is not automatically accessible in another.
- Theme delivery per platform: CSS custom properties scoped by theme (Web), `ThemeData` + `ThemeExtension` (Flutter), environment-injected theme object (SwiftUI), `CompositionLocal` theme (Compose).
- Visual regression references (§2.1) are captured per theme × mode.

**Light and dark modes (required)**

Dark mode is a second axis inside each theme, not a separate theme. Four combinations must be supported on every Phase 1 platform:

| | Light | Dark |
|---|---|---|
| **Polinom.io** | ✅ | ✅ |
| **TreatMint** | ✅ | ✅ |

- Mode changes only semantic token values; semantic names are shared across all four combinations.
- Default follows the OS/browser setting (`prefers-color-scheme`, `MediaQuery.platformBrightness`, `colorScheme`, `isSystemInDarkTheme()`), with a user override where the product offers one. Web pages must avoid a flash of the wrong mode on load.
- **Web attributes (v0.35):** two attributes on the root element. `data-theme="px"` or `"treatmint"` sets the brand (fixed per site); `data-mode="light"` or `"dark"` sets the mode. The token build emits, per theme: light values under `[data-theme="x"]`, dark values under `[data-theme="x"][data-mode="dark"]`, and the same dark values inside `@media (prefers-color-scheme: dark)` scoped to `[data-theme="x"]:not([data-mode])`. With no `data-mode`, the browser's setting decides in CSS alone, so the first paint is right before any JavaScript runs (no flash). A user override sets `data-mode` from a small inline script in `<head>` that reads the stored choice; the stored choice, not the OS, wins when present. The root also sets `color-scheme` to match. The combined form (`data-theme="px-dark"`) is not used. The design system page generates its own `tokens.css` from `tokens.json` with the combined form and that cannot be configured, so the page's copy is a preview only; the shipped file is the build's (`tools/build-web-css.mjs`). Type roles with non-zero letter spacing also export `--text-<role>-tracking`, because the `font` shorthand cannot carry it.
- Dark palettes are designed, not inverted: avoid pure black backgrounds, reduce saturation of brand colors, and re-check every semantic color for contrast.
- Elevation in dark mode is expressed by lighter surface tones, not shadows alone (FND-06).
- Imagery: logos, illustrations and any brand imagery need dark-mode variants or must be verified legible on dark surfaces.
- Theme × mode completeness is validated in the token build: every semantic token must have a value in all four combinations.

Tokens (§5.0) are the shared contract: authored once (e.g. DTCG JSON) and transformed per platform (CSS variables / TS, Dart, Swift, Kotlin). Components are implemented natively on each platform; behavior may differ where platform conventions require it, but naming, variants, and token usage must match.

### 2.3 Build approach

**Web (React): built in-house, no headless component library** (no Radix, React Aria, Headless UI, Ark, etc.). The system owns all markup, behavior, and accessibility.

Consequences and rules:
- **Behavior follows WAI-ARIA Authoring Practices (APG)** for every interactive component that has an APG pattern (Dialog, Menu, Tabs, Accordion, Combobox, Listbox, Tooltip, Disclosure). The spec (§7) names the APG pattern and its keyboard map.
- **Constraint — Astro host (v0.34):** Web components are written in React and consumed from **Astro** pages (both Web consumers, §2.1, are Astro sites). Every component must work as an Astro island:
  - **Server-render safe:** no `window`, `document`, `matchMedia` or layout reads during render; browser APIs only in effects or event handlers. Generate ids with `useId`, never `Math.random` or counters, so server and client markup match.
  - **No React context across components:** each island hydrates as its own React root, so a provider in one island is invisible to the next. Theme and mode reach components through CSS custom properties and the `data-theme` / `data-mode` attributes on the root (§2.2), never through a `ThemeProvider`. Components that need shared state (Accordion item and group, Tabs list and panel, Field and its control) ship as one compound unit that renders in a single island.
  - **Hydration cost is part of the API:** components with no behaviour (Card, Badge, Avatar, Button as a link, layout, content) render without client JavaScript and must not require hydration. Interactive components document the `client:*` directive they expect (default `client:visible`; `client:load` only for above-the-fold interaction such as the header menu). Server-rendered output is complete and usable before hydration where the platform allows it (links, native `details`, forms that submit without script).
  - **Props are serializable:** props passed across the island boundary are JSON-serializable (no functions, no JSX children from `.astro` beyond what Astro slots support). Callbacks are only for components rendered inside another React tree.
  - **Packaging:** ESM, tree-shakeable, one entry per component, CSS delivered as plain stylesheet files that Astro can bundle, with no CSS-in-JS runtime.
  - **Tests:** each Stable component is verified in an Astro build (static output and one hydrated island), in addition to the React-only test environment.
- **No third-party utility packages either** (no positioning engines, focus-trap, or similar). **Prefer native browser capabilities**; write in-house code only where the platform has no equivalent.
- **Exception — charts (any phase):** third-party charting libraries are allowed on every platform, at any phase. The full data-viz system is Phase 3, but a product needing a chart earlier (e.g. TreatMint) may use a library before then, under interim rules:
  - Use the same library that Phase 3 will standardize on for that platform, if already chosen; otherwise record the choice so Phase 3 can adopt or replace it deliberately.
  - Wrap the library in a thin product- or system-level component; products never style the library directly.
  - Colors come from existing semantic tokens (§2.2) in both themes and modes; no hard-coded chart colors.
  - Meet the chart accessibility rules from the Phase 3 outline (text alternative, data-table fallback, no color-only encoding).
  - Log each early chart in the audit log (§8) so Phase 3 can consolidate it.
- **Native-first capability map** (status as of Oct 2026; re-verify on [web-features](https://web-platform-dx.github.io/web-features-explorer/) before relying on it):

| Need | Native capability | Baseline status | Used by | Fallback (only if outside the support matrix) |
|---|---|---|---|---|
| Modal + focus trap + Esc + inert background | `<dialog>` + `showModal()` (top layer, `::backdrop`) | Widely available | Modal, Drawer, Alert dialog | — |
| Non-modal overlays, light dismiss, top layer | Popover API (`popover="auto"` / `"manual"`) | Newly available (2024) | Menu, Popover, Tooltip, Toast | — (within support matrix) |
| Declarative open/close without JS | Invoker commands (`command` / `commandfor`) | Newly available (Dec 2025) | Dialog, Popover, Drawer triggers | Small `click` handler calling `showModal()` / `showPopover()` |
| Anchoring + flip/shift at viewport edges | CSS anchor positioning (`anchor-name`, `position-anchor`, `position-try-fallbacks`) | Newly available (Jan 2026) | Tooltip, Popover, Menu, Select, Combobox | `@supports not (anchor-name: --a)` → fixed placement below/centered, no collision handling |
| Disclosure / exclusive accordion | `<details>` / `<summary>`, `name` attribute for one-open-at-a-time | Widely / Newly available | Accordion, FAQ section | — |
| Making background inert | `inert` attribute | Widely available | Drawer (non-dialog), off-canvas nav | — |
| Keyboard-only focus ring | `:focus-visible` | Widely available | All interactive | — |
| Theme / mode | CSS custom properties, `color-scheme`, `light-dark()`, `prefers-color-scheme` | Widely / Newly available | All (§2.2) | `light-dark()` → paired custom properties per mode |
| Reduced motion | `prefers-reduced-motion` | Widely available | All animated | — |
| Responsive components | Container queries | Widely available | Card, Feature grid, Hero | — |
| Native form controls | `<input type=date/time/number>`, `<select>` | Widely available | Date/Time picker (deferred), Select | — |
| Styled `<select>` | `appearance: base-select` | **Not Baseline** (Chromium only) | Select | Use only as `@supports` enhancement over a styled native `<select>`; do not depend on it |
| Hover/focus-triggered popovers | `interestfor`, `popover="hint"` | **Not Baseline** | Tooltip | Do not use yet; small in-house handler on top of Popover API |

- **Still built in-house** (no native equivalent): roving tabindex and arrow-key navigation (Menu, Tabs, Listbox, Radio group), typeahead in lists, `aria-live` announcer for Toast/async status, scroll lock for modals (CSS `:has(dialog[open])` + `overflow: hidden`), ID generation for label/description wiring.
- **Browser support policy: last 2 major versions** of each supported browser, desktop and mobile:

  | Browser | Platforms |
  |---|---|
  | Chrome | Desktop, Android |
  | Edge | Desktop |
  | Firefox | Desktop, Android |
  | Safari | macOS, iOS / iPadOS |

  Codified as an explicit `browserslist` (bare `last 2 versions` also pulls in dead browsers such as Opera Mini and IE, so it is not used):
  ```
  last 2 Chrome versions
  last 2 Edge versions
  last 2 Firefox versions
  last 2 FirefoxAndroid versions
  last 2 ChromeAndroid versions
  last 2 Safari versions
  last 2 iOS versions
  ```
  Consequences:
  - Every *Baseline* capability in the map above (including *Newly available* ones: Popover API, invoker commands, anchor positioning, exclusive `<details>`, `light-dark()`) is supported across this matrix, so it is **used directly, without fallback code**. The fallback column is kept for reference only.
  - *Not Baseline* features (`appearance: base-select`, `interestfor`, `popover="hint"`) remain progressive enhancement behind `@supports` / feature detection until supported by every browser in the matrix.
  - Browsers outside the matrix (older iOS devices that cannot update, Samsung Internet, Firefox ESR, in-app webviews) are not tested. Content must remain readable and links/forms usable (graceful degradation), but overlays and positioning may be degraded.
  - The matrix is re-evaluated each release; a native feature may be adopted once it is supported by every browser in the matrix.
- **Risk is concentrated** in Dialog, Menu, Popover, Tooltip and Tabs (needed for Phase 1 Web). Combobox, Date picker and other complex widgets are deferred on Web (§2.1), which keeps Phase 1 scope manageable.
- **Testing is mandatory, not optional:** automated a11y checks (axe) in CI, keyboard interaction tests per component, and manual screen-reader passes (NVDA + VoiceOver) before `Stable`.

**Flutter, iOS native, Android native:** build on each framework's own primitives (Flutter widgets, SwiftUI/UIKit, Jetpack Compose foundation), which already provide platform semantics and accessibility. Styling is applied through the theme layer (§2.2); avoid wrapping framework widgets in ways that strip their built-in semantics.

**Inclusion rule:** a component enters the system when it appears in **≥ 2 products or ≥ 3 distinct screens**, or is a foundational primitive other components depend on.

---

## 3. Field definitions & legends

### 3.1 Inventory fields

| Field | Description |
|---|---|
| **ID** | Stable identifier, e.g. `ACT-01`. Never reused. |
| **Component** | Canonical name (singular, PascalCase in code). |
| **Aliases** | Names found in the wild; helps dedupe and search. |
| **Level** | `Primitive` · `Component` · `Composite` · `Pattern` (see 3.2). |
| **Variants** | Visual/semantic variations exposed as props. |
| **States** | Interactive/system states to design and test. |
| **Depends on** | Tokens/components it is built from. |
| **Priority** | `P0` · `P1` · `P2` · `P3` (see §4). |
| **Usage** | Instance count from audit, or `High/Med/Low`. |
| **Design / Code / Docs** | Lifecycle status per track (see 3.3). **Code** shows the *lowest* status across the current phase's platforms (Phase 1: Web + Flutter), so it reads `—` until every Phase 1 platform has started; per-platform detail lives in the component spec (§7) and, until specs exist, in §5.11. |
| **Owner** | Accountable person or squad. |

### 3.2 Levels

| Level | Definition | Examples |
|---|---|---|
| **Primitive** | Smallest building block; no other components inside. | Icon, Text, Box, Divider |
| **Component** | Self-contained interactive or display unit. | Button, Input, Checkbox, Badge |
| **Composite** | Combines several components with fixed structure. | Card, Modal, Data table, Date picker |
| **Pattern** | Recommended arrangement/flow; may be guidance only. | Empty state, Form layout, Filtering |

### 3.3 Lifecycle status

| Status | Meaning |
|---|---|
| `—` Not started | Identified, no work begun |
| `Proposed` | Under review for inclusion |
| `In design` | Spec and design in progress |
| `In build` | Implementation in progress |
| `Beta` | Usable; API may change |
| `Stable` | Production-ready, versioned, documented |
| `Deprecated` | Replacement exists; removal scheduled |
| `Won't do` | Deliberately excluded (log reason in Notes) |

---

## 4. Prioritization rubric

Score each component 1–3 on each criterion; sum determines priority.

| Criterion | 1 | 2 | 3 |
|---|---|---|---|
| **Usage frequency** | Rare | Several screens | Nearly every screen |
| **Inconsistency today** | Already consistent | Some drift | Many divergent versions |
| **Dependency weight** | Leaf (nothing depends on it) | Some dependents | Many components depend on it |
| **Risk (a11y / brand / legal)** | Low | Medium | High |

| Score | Priority | Target |
|---|---|---|
| 10–12 | **P0** | Foundation release (v1.0) |
| 7–9 | **P1** | v1.x |
| 5–6 | **P2** | Backlog, build on demand |
| ≤ 4 | **P3** | Pattern guidance only, or `Won't do` |

> Dependency weight matters most for build order: a P1 primitive that a P0 component depends on must ship first regardless of its own score.

---

## 5. Component inventory

Default priorities below are suggestions; re-score after the audit.

### 5.0 Foundations (tokens) — prerequisite for all components

| ID | Foundation | Contents | Priority | Design | Code | Docs | Owner |
|---|---|---|---|---|---|---|---|
| FND-01 | Color | Primitive palettes per brand (Polinom.io, TreatMint); semantic roles: action, neutral, feedback (success/warning/danger/info), surface, border, text; themes and light/dark modes per §2.2 — **v0.20:** Polinom.io = Solarized high-contrast + 10 AA contrast additions; TreatMint = logo Direction B palette (Teal, Deep mint, Mist) + UI colors from the v1.1 sheet (v0.24). **v0.26:** refactored into four shared-slot categories (Neutrals, Brand, Accents, Status); Polinom.io brand violet + orange, accents cyan + magenta; TreatMint secondary Lavender; term colours removed (§2.2). **v0.28:** dropped and rebuilt from scratch for Polinom.io: neutrals from the logo ground, brand blue / orange / cyan, accents magenta / violet / teal / clay, new status colours; TreatMint unchanged; `tone` has four values (§2.2). **v0.29:** brand primary back to violet (logo colours); secondary accent is blue. **v0.31:** TreatMint accents tertiary gold and quaternary orchid replace the repeats of primary and secondary. | P0 | In design | — | In design | Core team |
| FND-02 | Typography | Font families, scale, weights, line heights, letter spacing; typography roles (§5.0.1) in the theme layer (TreatMint aliases Polinom.io in Phase 1, see §2.2) — **v0.20:** Atkinson Hyperlegible Next (variable 200–800) for every role except code; Hack 3.3.0 for `code-md`. | P0 | In design | — | In design | Core team |
| FND-03 | Spacing | Base unit (e.g. 4px) and scale — **v0.20:** 4px base, `space-0`…`space-24`. | P0 | In design | — | In design | Core team |
| FND-04 | Sizing | Control heights (sm/md/lg), icon sizes, touch targets (≥ 44×44 / 48×48dp) — **v0.20:** controls 32/40/48px, icons 16/20/24px, touch min 44pt / 48dp. | P0 | In design | — | In design | Core team |
| FND-05 | Radius | Corner radius scale — **v0.20:** 0/4/8/12/20px + full. | P0 | In design | — | In design | Core team |
| FND-06 | Elevation | Shadow levels and z-index layers; dark-mode surface tones per level — **v0.20:** 4 shadow levels per theme × mode; Polinom.io dark has only two surface tones (borders carry the rest). | P0 | In design | — | In design | Core team |
| FND-07 | Border | Widths, styles — **v0.20:** hairline 1px, thick 2px, focus 2px. | P0 | In design | — | In design | Core team |
| FND-08 | Motion | Durations, easings, reduced-motion behavior — **v0.20:** durations and easings documented as guidance; not yet tokens. **v0.27:** moved to the sidecar DTCG file `motion.tokens.json` (`tokens/motion.tokens.json`): `motion-duration-fast/-medium/-slow` 120/200/280ms, `motion-easing-enter/-exit`; the token build merges it with `tokens.json`. | P1 | In design | — | In design | Core team |
| FND-09 | Breakpoints & grid | Breakpoints, columns, gutters, max widths — **v0.20:** 640/768/1024/1280px; 4/8/12 columns; max width 1200px. | P0 | In design | — | In design | Core team |
| FND-10 | Iconography | Icon set, grid, stroke, naming — **v0.20:** Phosphor 2.1.1, regular at rest, fill for selected only; 35 starter icons. | P0 | In design | — | In design | Core team |
| FND-11 | Opacity / state layers | Hover, pressed, disabled, scrim values — **v0.20:** hover 0.08, pressed 0.12, disabled 0.38, scrim per theme × mode. | P1 | In design | — | In design | Core team |
| FND-12 | Theme definitions | Polinom.io and TreatMint × light/dark semantic→primitive mappings; completeness and contrast validation in build — **v0.20:** all four combinations defined; contrast validated by script, not yet in a build. | P0 | In design | — | In design | Core team |

#### 5.0.1 Typography roles

Components and product screens reference **only** these role tokens; never font families, raw sizes or weights (§2.2). Each role bundles family, size, line height, weight and letter spacing. Values are defined per theme; in Phase 1 the TreatMint theme aliases Polinom.io.

| Role token | Purpose | Typical use | Family | Size / line height | Weight | Letter spacing | Web responsive | iOS Dynamic Type style | 
|---|---|---|---|---|---|---|---|---|
| `display-lg` | Largest marketing headline | Hero (MKT-01) | Atkinson Hyperlegible Next | 64 / 68px | 700 | −0.02em | Scales down on small viewports | `largeTitle` |
| `display-md` | Secondary marketing headline | CTA section, feature headers | Atkinson Hyperlegible Next | 48 / 52px | 700 | −0.015em | Scales down on small viewports | `largeTitle` |
| `heading-lg` | Page title (H1) | Page header (LAY-07) | Atkinson Hyperlegible Next | 36 / 44px | 600 | −0.01em | Optional | `title1` |
| `heading-md` | Section title (H2) | Section headers | Atkinson Hyperlegible Next | 28 / 36px | 600 | −0.005em | — | `title2` |
| `heading-sm` | Subsection title (H3/H4) | Sub-sections, FAQ group titles | Atkinson Hyperlegible Next | 22 / 28px | 600 | 0 | — | `title3` |
| `title-md` | Container title | Card, Modal, Drawer titles | Atkinson Hyperlegible Next | 18 / 26px | 600 | 0 | — | `headline` |
| `title-sm` | Small container title | List item primary text, Accordion header | Atkinson Hyperlegible Next | 16 / 24px | 600 | 0 | — | `subheadline` |
| `body-lg` | Lead paragraph | Hero subtext, intro copy | Atkinson Hyperlegible Next | 18 / 28px | 400 | 0 | — | `body` (+ size offset) |
| `body-md` | Default body text | Paragraphs, descriptions | Atkinson Hyperlegible Next | 16 / 24px | 400 | 0 | — | `body` |
| `body-sm` | Compact body text | Dense lists, table cells | Atkinson Hyperlegible Next | 14 / 20px | 400 | 0 | — | `callout` |
| `label-md` | Control label | Buttons, Tabs, form Labels, Menu items | Atkinson Hyperlegible Next | 14 / 20px | 500 | 0 | — | `callout` |
| `label-sm` | Small control label | Small buttons, Tags/Chips, Badges | Atkinson Hyperlegible Next | 12 / 16px | 500 | 0 | — | `footnote` |
| `caption-sm` | Supporting text | Helper/error text, timestamps, metadata | Atkinson Hyperlegible Next | 12 / 16px | 400 | 0 | — | `caption1` |
| `code-md` | Monospace text | Code block, Kbd | Hack | 14 / 20px | 400 | 0 | — | `body` (monospaced) |

**Family tokens:** `font-brand` (display/headings), `font-body` (UI and reading text), `font-mono`. In v0.20 brand and body are both Atkinson Hyperlegible Next and mono is Hack; the separation exists so TreatMint can diverge later (§2.2 decision point). Sizes above are px at the default 16px root; tokens are authored in rem.

**Platform delivery**
- **Web:** one CSS `font` shorthand custom property per role (e.g. `--text-heading-lg`), generated from `tokens.json`, plus one utility class per role; display roles use breakpoint or `clamp()` sizing; sizes in `rem` so browser zoom/font settings apply.
- **Flutter:** roles exposed via a `ThemeExtension` (or mapped onto `TextTheme`); respect `MediaQuery.textScaler`.
- **iOS native:** custom `Font` per role, scaled relative to the mapped Dynamic Type style (`Font.custom(_:size:relativeTo:)`).
- **Android native:** `TextStyle` per role in the Compose typography, sizes in `sp` so system font scale applies.

**Rules**
- The role set is closed: adding, renaming or removing a role is a core-team decision (§10.1). A request for a new role is first checked against existing roles; most are design inconsistencies, not real needs.
- Lint on every platform flags font family names, raw font sizes, and raw weights outside the token/theme packages.
- Headings carry semantic level separately from visual role: e.g. a card title can be an `<h3>` rendered with `title-md`. The role sets appearance; markup/semantics set structure.
- Every role must remain legible at 200% text scaling without clipping or overlap (§6).

### 5.1 Actions

| ID | Component | Aliases | Level | Variants | States | Depends on | Priority | Design | Code | Docs | Owner |
|---|---|---|---|---|---|---|---|---|---|---|---|
| ACT-01 | Button | CTA, Btn | Component | Primary, Secondary, Tertiary/Ghost, Destructive; sm/md/lg; with leading/trailing icon | Default, Hover, Focus, Pressed, Disabled, Loading | Text, Icon, Spinner | P0 | In design | — | In design |  |
| ACT-02 | Icon button | Action icon | Component | Filled, Outline, Ghost; sizes | Same as Button + Toggled | Icon, Tooltip | P0 | — | — | — | |
| ACT-03 | Link | Anchor, Text link | Component | Inline, Standalone, External | Default, Hover, Focus, Visited, Disabled | Text, Icon | P0 | — | — | — | |
| ACT-04 | Button group | Segmented buttons | Composite | Attached, Spaced | Per child | Button | P2 | — | — | — | |
| ACT-05 | Split button | Dropdown button | Composite | Primary/Secondary | Per child + Menu open | Button, Menu | P2 | — | — | — | |
| ACT-06 | Floating action button | FAB | Component | Standard, Extended, Mini | Default, Hover, Focus, Pressed | Icon | P3 | — | — | — | |
| ACT-07 | Toggle button | Pressable, Toggle | Component | Single, Grouped | On, Off, Disabled, Focus | Button | P2 | — | — | — | |

### 5.2 Inputs & forms

| ID | Component | Aliases | Level | Variants | States | Depends on | Priority | Design | Code | Docs | Owner |
|---|---|---|---|---|---|---|---|---|---|---|---|
| INP-01 | Text input | Text field, Input | Component | sm/md/lg; prefix/suffix; with icon; clearable | Default, Hover, Focus, Filled, Disabled, Read-only, Error, Success | Label, Helper text, Icon | P0 | In design | — | In design |  |
| INP-02 | Text area | Multiline input | Component | Fixed, Auto-grow; with counter | As Text input | Label, Helper text | P0 | In design | — | In design |  |
| INP-03 | Select | Dropdown, Picker | Composite | Native, Custom; single | As Text input + Open | Menu/Listbox, Icon | P0 | In design | — | In design |  |
| INP-04 | Combobox | Autocomplete, Typeahead | Composite | Single, Multi (with tags); async | As Select + Loading, No results | Text input, Listbox, Tag, Spinner | P1 | — | — | — | |
| INP-05 | Checkbox | Check | Component | Standalone, With label | Unchecked, Checked, Indeterminate, Disabled, Focus, Error | Icon | P0 | In design | — | In design |  |
| INP-06 | Radio | Radio button | Component | Standalone, Group | Unselected, Selected, Disabled, Focus, Error | — | P0 | — | — | — | |
| INP-07 | Switch | Toggle | Component | With/without label; sm/md | Off, On, Disabled, Focus, Loading | — | P0 | In design | — | In design |  |
| INP-08 | Slider | Range | Component | Single, Range; with steps/marks | Default, Hover, Focus, Dragging, Disabled | Tooltip | P0 | — | — | — | |
| INP-09 | Date picker | Calendar input | Composite | Single, Range; inline/popover | As Text input + Open | Text input, Calendar, Popover | P1 | — | — | — | |
| INP-10 | Time picker | — | Composite | 12h/24h | As Text input | Text input, Listbox | P0 | — | — | — | |
| INP-11 | File upload | Dropzone, Uploader | Composite | Button, Dropzone; single/multi | Idle, Drag-over, Uploading, Success, Error | Button, Progress, Icon | P1 | — | — | — | |
| INP-12 | Search field | Search bar | Component | Standalone, In header; with filters | As Text input + Searching | Text input, Icon button | P1 | — | — | — | |
| INP-13 | Number input | Stepper, Spinbutton | Component | With/without steppers | As Text input | Text input, Icon button | P2 | — | — | — | |
| INP-14 | Label | Field label | Primitive | Required, Optional indicator | Default, Disabled | Text | P0 | In design | — | In design |  |
| INP-15 | Helper / error text | Hint, Validation message | Primitive | Helper, Error, Success | — | Text, Icon | P0 | In design | — | In design |  |
| INP-16 | Form field | Field wrapper | Composite | Vertical, Horizontal | Inherits from control | Label, Helper text, any input | P0 | In design | — | In design |  |
| INP-17 | Fieldset | Field group | Composite | With legend | Default, Disabled, Error | Label | P1 | — | — | — | |
| INP-18 | OTP / PIN input | Code input | Composite | 4/6 digits | Default, Focus, Error, Filled | Text input | P3 | — | — | — | |
| INP-19 | Body outline | Body map, Body diagram, Body region picker | Composite | Front, Back (switchable); select one or several regions; display-only (highlights regions). Regions named by side, area and face ("Left knee, front"). Artwork: a simple, custom-made body form drawn for the system, coloured by tokens in all four themes. Used in TreatMint's Log pain, Pain history and Treatments screens. **Flutter only**; Web `Won't do` until a web consumer exists | Region: Default, Hover, Focus, Selected, Disabled; whole: Default, Disabled, Error | Illustration (body artwork, light/dark), Toggle button (front/back), Text, Helper / error text | P0 | In design | — | In design | |

### 5.3 Navigation

| ID | Component | Aliases | Level | Variants | States | Depends on | Priority | Design | Code | Docs | Owner |
|---|---|---|---|---|---|---|---|---|---|---|---|
| NAV-01 | Top bar / Header | App bar, Navbar | Composite | Default, Compact, Transparent | Default, Scrolled | Logo, Link, Icon button, Avatar, Menu | P0 | — | — | — | |
| NAV-02 | Side navigation | Sidebar, Nav drawer | Composite | Expanded, Collapsed, Overlay (mobile) | Item: Default, Hover, Active, Focus | Link, Icon, Badge | P1 | — | — | — | |
| NAV-03 | Tabs | Tab bar | Component | Line, Contained/Pill; scrollable | Default, Hover, Selected, Focus, Disabled | Text, Icon, Badge | P0 | In design | — | In design |  |
| NAV-04 | Breadcrumbs | Trail | Component | With truncation/overflow | Default, Hover, Current | Link, Menu | P1 | — | — | — | |
| NAV-05 | Pagination | Pager | Component | Numbered, Simple (prev/next), Load more | Default, Hover, Current, Disabled | Button, Icon button | P1 | — | — | — | |
| NAV-06 | Stepper | Progress steps, Wizard | Component | Horizontal, Vertical | Upcoming, Current, Complete, Error | Icon, Text | P2 | — | — | — | |
| NAV-07 | Bottom navigation | Tab bar (mobile) | Composite | 3–5 items; with labels | Default, Selected | Icon, Text, Badge | P0 | — | — | — | |
| NAV-08 | Menu | Dropdown menu, Context menu | Composite | With icons, shortcuts, sections, checkable items | Item: Default, Hover, Focus, Disabled, Selected | Popover, Divider, Icon | P0 | — | — | — | |
| NAV-09 | Skip link | Skip to content | Component | — | Hidden, Focused | Link | P0 | — | — | — | |
| NAV-10 | Footer | Site footer | Composite | Minimal, Full | — | Link, Text, Divider | P1 | — | — | — | |

### 5.4 Feedback & status

| ID | Component | Aliases | Level | Variants | States | Depends on | Priority | Design | Code | Docs | Owner |
|---|---|---|---|---|---|---|---|---|---|---|---|
| FBK-01 | Alert / Banner | Inline message, Callout | Component | Info, Success, Warning, Error; inline/page-level; dismissible | Default, Dismissed | Icon, Text, Button | P0 | In design | — | In design |  |
| FBK-02 | Toast | Snackbar, Notification | Component | Info, Success, Warning, Error; with action | Entering, Visible, Exiting | Icon, Button | P1 | — | — | — | |
| FBK-03 | Spinner | Loader | Primitive | sm/md/lg; inline/overlay | — | — | P0 | — | — | — | |
| FBK-04 | Progress bar | Linear progress | Component | Determinate, Indeterminate; with label | — | — | P1 | In design | — | In design |  |
| FBK-05 | Skeleton | Placeholder, Shimmer | Primitive | Text, Circle, Rect; presets per composite | Animated, Static (reduced motion) | — | P1 | — | — | — | |
| FBK-06 | Badge | Count, Dot | Primitive | Numeric, Dot; semantic colors | — | Text | P1 | In design | — | In design |  |
| FBK-07 | Status indicator | Status dot, Pill | Primitive | Online, Offline, Busy, Neutral; with label | — | Text | P2 | — | — | — | |
| FBK-08 | Empty state | Zero state, No results | Pattern | First use, No results, Error, No permission | — | Illustration/Icon, Text, Button | P1 | — | — | — | |

### 5.5 Overlays

| ID | Component | Aliases | Level | Variants | States | Depends on | Priority | Design | Code | Docs | Owner |
|---|---|---|---|---|---|---|---|---|---|---|---|
| OVL-01 | Modal / Dialog | Popup, Lightbox | Composite | sm/md/lg/fullscreen; Alert dialog (confirm/destructive) | Opening, Open, Closing | Overlay/Scrim, Button, Icon button | P0 | In design | — | In design |  |
| OVL-02 | Drawer / Sheet | Side panel, Bottom sheet | Composite | Left, Right, Bottom; modal/non-modal | Opening, Open, Closing | Overlay/Scrim, Icon button | P1 | — | — | — | |
| OVL-03 | Popover | Flyout | Primitive | With/without arrow; placements | Open, Closed | Elevation tokens | P0 | — | — | — | |
| OVL-04 | Tooltip | Hint | Component | Placements; text-only | Hidden, Visible | Popover | P0 | — | — | — | |
| OVL-05 | Overlay / Scrim | Backdrop | Primitive | Light, Dark | — | Opacity tokens | P0 | — | — | — | |
| OVL-06 | Command palette | Quick search, Spotlight | Composite | — | Open, Searching, Empty | Modal, Search field, Listbox | P3 | — | — | — | |

### 5.6 Data display

| ID | Component | Aliases | Level | Variants | States | Depends on | Priority | Design | Code | Docs | Owner |
|---|---|---|---|---|---|---|---|---|---|---|---|
| DSP-01 | Card | Tile, Panel | Composite | Default, Outlined, Elevated; interactive/static; with media | Default, Hover, Focus, Selected (if interactive) | Box, Text, Button, Image | P0 | In design | — | In design |  |
| DSP-02 | Data table | Table, Grid | Composite | Basic, Sortable, Selectable, Expandable rows; dense/comfortable. **Web: Basic only** (static content table); Sortable, Selectable and Expandable deferred on Web until an app consumer exists (§2.1) | Row: Default, Hover, Selected; Loading, Empty | Checkbox, Pagination, Menu, Skeleton, Empty state | P0 | In design | — | In design |  |
| DSP-03 | List | List item, Row | Component | Single-line, Two-line; with avatar/icon/action | Default, Hover, Focus, Selected, Disabled | Text, Icon, Avatar, Checkbox | P0 | — | — | — | |
| DSP-04 | Avatar | Profile picture | Primitive | Image, Initials, Icon; sizes; with status | Default, Fallback | Image, Status indicator | P1 | In design | — | In design |  |
| DSP-05 | Avatar group | Stacked avatars | Composite | With overflow count | — | Avatar | P2 | — | — | — | |
| DSP-06 | Tag / Chip | Pill, Label, Token | Component | Static, Removable, Selectable/Filter; semantic colors | Default, Hover, Selected, Focus, Disabled | Text, Icon button | P1 | — | — | — | |
| DSP-07 | Accordion | Collapsible, Expander | Component | Single, Multi-expand | Collapsed, Expanded, Focus, Disabled | Icon, Divider | P1 | — | — | — | |
| DSP-08 | Description list | Key-value, Detail list | Component | Stacked, Inline | — | Text | P2 | — | — | — | |
| DSP-09 | Stat / KPI | Metric, Number tile | Component | With trend; With sparkline (charting library allowed, see §2.3 chart exception) | Loading | Text, Icon | P0 | In design | — | In design |  |
| DSP-10 | Timeline | Activity feed | Composite | Vertical; with icons | — | Icon, Text, Avatar | P3 | — | — | — | |
| DSP-11 | Tree view | Hierarchy | Composite | With checkboxes | Collapsed, Expanded, Selected, Focus | Icon, Checkbox | P3 | — | — | — | |
| DSP-12 | Calendar | Month view | Composite | Single, Range selection | Day: Default, Today, Selected, In-range, Disabled | Icon button, Text | P0 | — | — | — | |
| DSP-13 | Code block | Snippet | Component | Inline, Block; with copy | — | Icon button | P3 | — | — | — | |

### 5.7 Layout & structure

| ID | Component | Aliases | Level | Variants | States | Depends on | Priority | Design | Code | Docs | Owner |
|---|---|---|---|---|---|---|---|---|---|---|---|
| LAY-01 | Box | View, Container | Primitive | — (token-driven props) | — | Spacing, Color, Radius tokens | P0 | — | — | — | |
| LAY-02 | Stack | Flex, VStack/HStack | Primitive | Vertical, Horizontal; gap | — | Spacing tokens | P0 | — | — | — | |
| LAY-03 | Grid | Layout grid | Primitive | Columns, responsive spans | — | Breakpoint/grid tokens | P0 | — | — | — | |
| LAY-04 | Container | Page width | Primitive | sm/md/lg/full | — | Breakpoint tokens | P0 | — | — | — | |
| LAY-05 | Divider | Separator, HR | Primitive | Horizontal, Vertical; with label | — | Border tokens | P0 | — | — | — | |
| LAY-06 | Page layout / App shell | Template, Frame | Pattern | Header + content; sidebar + content | — | Top bar, Side nav, Container | P1 | — | — | — | |
| LAY-07 | Section header | Page header | Composite | With actions, breadcrumbs, tabs | — | Text, Button, Breadcrumbs, Tabs | P1 | — | — | — | |
| LAY-08 | Visually hidden | SR-only | Primitive | — | — | — | P0 | — | — | — | |

### 5.8 Content & media

| ID | Component | Aliases | Level | Variants | States | Depends on | Priority | Design | Code | Docs | Owner |
|---|---|---|---|---|---|---|---|---|---|---|---|
| CNT-01 | Text | Typography, Body | Primitive | Display, Heading 1–6, Body, Caption, Overline, Mono | — | Typography tokens | P0 | — | — | — | |
| CNT-02 | Icon | Glyph | Primitive | Sizes; decorative vs. meaningful | — | Icon set | P0 | — | — | — | |
| CNT-03 | Image | Picture, Media | Primitive | Aspect ratios; fit/fill; rounded | Loading, Loaded, Error/Fallback | Skeleton | P1 | — | — | — | |
| CNT-04 | Logo | Brand mark | Primitive | Horizontal, Stacked, Mono, Icon, Favicon, App icon; light/dark per brand (Polinom.io 12 files, TreatMint 13 files in `assets/Logos/`) | — | — | P0 | In design | — | In design | |
| CNT-05 | Illustration | Spot art | Primitive | Empty, Error, Success sets; light/dark variants | — | — | P2 | — | — | — | |
| CNT-06 | Video player | Media player | Composite | Inline, Fullscreen | Playing, Paused, Buffering, Error | Icon button, Slider | P3 | — | — | — | |
| CNT-07 | Carousel | Slider, Gallery | Composite | With dots/arrows; autoplay off by default | Per slide | Icon button | P3 | — | — | — | |
| CNT-08 | Kbd | Keyboard key | Primitive | — | — | Text | P3 | — | — | — | |

### 5.9 Patterns (guidance, not necessarily components)

| ID | Pattern | Covers | Uses | Priority | Docs | Owner |
|---|---|---|---|---|---|---|
| PAT-01 | Form layout & validation | Field order, inline vs. on-submit validation, error summary | Form field, Alert, Button | P0 | — | |
| PAT-02 | Loading | When to use spinner vs. skeleton vs. progress; optimistic UI | Spinner, Skeleton, Progress | P1 | — | |
| PAT-03 | Empty & error states | First-use, no results, 404/500, permission denied | Empty state, Button | P1 | — | |
| PAT-04 | Confirmation & destructive actions | When to confirm, undo vs. confirm dialog | Modal, Toast, Button | P1 | — | |
| PAT-05 | Filtering & sorting | Filter bar, chips, applied-filters summary | Tag, Select, Search field, Menu | P2 | — | |
| PAT-06 | Notifications | Toast vs. banner vs. inbox; priority and stacking | Toast, Alert, Badge | P2 | — | |
| PAT-07 | Authentication | Sign-in, sign-up, reset, MFA flows | Form field, Button, OTP input | P2 | — | |
| PAT-08 | Onboarding | Tours, checklists, coach marks | Popover, Stepper | P3 | — | |

### 5.10 Marketing sections (Web only)

Reusable page sections for the Polinom.io landing page and the TreatMint product page. Web (React) only; not planned for Flutter or native.

| ID | Component | Aliases | Level | Variants | States | Depends on | Priority | Design | Code | Docs | Owner |
|---|---|---|---|---|---|---|---|---|---|---|---|
| MKT-01 | Hero | Masthead, Banner | Composite | Centered, Split (text + media), With background image/video | — | Text, Button, Image, Container | P1 | — | — | — | |
| MKT-02 | Feature grid | Features, Benefits | Composite | 2/3/4 columns; icon or image; alternating rows | — | Card, Icon, Text, Grid | P1 | — | — | — | |
| MKT-03 | CTA section | Call-to-action band | Composite | Inline, Full-width band; with secondary action | — | Text, Button, Container | P1 | — | — | — | |
| MKT-04 | FAQ section | Questions | Composite | Single/two-column | Per Accordion | Accordion, Text | P1 | — | — | — | |
| MKT-05 | Logo cloud | Partners, Clients | Composite | Static grid, Scrolling (respects reduced motion) | — | Image, Grid | P2 | — | — | — | |
| MKT-06 | Pricing table | Plans | Composite | 2–4 tiers; monthly/annual toggle; highlighted tier | — | Card, Button, Toggle button, Text | P2 | — | — | — | |
| MKT-07 | Testimonial | Quote, Customer story | Composite | Single, Grid; with avatar/logo | — | Avatar, Text, Card | P2 | — | — | — | |
| MKT-08 | Signup / contact form section | Newsletter, Lead form | Composite | Inline email capture, Full contact form | Default, Submitting, Success, Error | Form field, Text input, Button, Alert | P2 | — | — | — | |

### 5.11 Phase 1 build progress by platform

Until each component has a spec (§7), per-platform progress is tracked here. The Code column in §5.0–§5.10 shows the lowest status across Web and Flutter, so these rows read `—` there.

The 14 React components in the Polinom.io design system (migrated from the 27 Oct system and rebuilt on current tokens) cover **18 inventory rows**, because Field implements six rows.

| Design-system component | Inventory rows | Web (React) | Flutter |
|---|---|---|---|
| Button | ACT-01 | In build | — |
| Field | INP-16 Form field, INP-01 Text input, INP-02 Text area, INP-03 Select, INP-14 Label, INP-15 Helper / error text | In build | — |
| Checkbox | INP-05 | In build | — |
| Switch | INP-07 | In build | — |
| Tabs | NAV-03 | In build | — |
| Alert | FBK-01 | In build | — |
| Progress | FBK-04 | In build | — |
| Badge | FBK-06 | In build | — |
| Modal | OVL-01 | In build | — |
| Card | DSP-01 | In build | — |
| Table | DSP-02 (Basic only) | In build | — |
| Stat | DSP-09 | In build | — |
| Avatar | DSP-04 | In build | — |
| CurveDivider | none: a Polinom.io brand ornament, tracked as a LAY-05 Divider variant (LAY-05 itself not started) | In build | Won't do (marketing only) |

The bundle's internal `Icon` helper renders Phosphor icons inside these components; it is not the CNT-02 Icon component.

---

## 6. Accessibility baseline (applies to every component)

A component cannot reach `Stable` without meeting all of these. Target: **WCAG 2.2 AA**.

- [ ] Text contrast ≥ 4.5:1 (≥ 3:1 for large text); non-text UI and focus indicators ≥ 3:1, in every theme × mode (Polinom.io/TreatMint × light/dark)
- [ ] Fully operable by keyboard; logical focus order; no keyboard traps (except intentional modal focus trap with Esc to exit)
- [ ] Visible focus indicator on every interactive element
- [ ] Correct semantics/roles; follows the relevant WAI-ARIA Authoring Practices pattern where one exists
- [ ] Accessible name for every interactive element (icon-only controls included)
- [ ] State changes announced (expanded, selected, checked, invalid, busy)
- [ ] Target size ≥ 24×24 CSS px (WCAG 2.2 minimum); 44×44 recommended for touch
- [ ] Respects `prefers-reduced-motion`
- [ ] Works at 200% zoom and 320px viewport width without loss of content
- [ ] Information never conveyed by color alone
- [ ] Tested with at least one screen reader per platform: Web (NVDA/JAWS + VoiceOver macOS), iOS native and Flutter-on-iOS (VoiceOver), Android native and Flutter-on-Android (TalkBack)
- [ ] Supports platform text scaling (Dynamic Type on iOS, font scale on Android, `textScaler` in Flutter)
- [ ] Status and `tone` colours always paired with an icon, word or label, per §6.1

### 6.1 Colour-vision deficiency (CVD) check

A sanity pass on top of the baseline. The rule "information never conveyed by colour alone" already applies; this check shows **where** colour fails as an at-a-glance cue, so components put the non-colour cue there.

**Method (5 Nov 2026):** `tokens.json` resolved per theme × mode; Machado et al. (2009) simulation at full severity (protanopia, deuteranopia, tritanopia), CIEDE2000 between the simulated pair. Bands for quick scanning: ΔE00 ≥ 20 distinct, 10–20 marginal, < 10 confusable. Full severity models dichromats (≈2% of men); anomalous trichromats (≈6%) see more difference than this. Script: `tools/cvd-check.mjs` (Node port, v0.45; same results as the original Python script).

| Theme × mode | Confusable (< 10) under protan/deutan | Marginal (10–20) |
|---|---|---|
| Polinom.io light (v0.32) | — | success / warning (13.1), success / danger (12.2), warning / danger (12.2); tone magenta / blue (12.6), magenta / teal (11.1), blue / teal (15.9) |
| Polinom.io dark (v0.29) | tone magenta / teal (8.7), teal / clay (9.7) | success / warning (12.5), success / danger (16.7), warning / danger (16.4); tone magenta / blue (11.9), magenta / clay (10.2), blue / teal (15.8) |
| TreatMint light (v0.32) | tone mint / orchid (9.0), lavender / orchid (9.9) | success / info (15.6), warning / danger (15.0); tone mint / gold (17.1) |
| TreatMint dark (v0.31) | tone mint / orchid (9.7), lavender / orchid (9.0) | success / info (13.1), warning / danger (13.9) |

v0.28 moved Polinom.io success / danger from 4.4 (light) and 12.6 (dark) to 16.1 and 16.7 by separating them in lightness. v0.32 closed the remaining light-mode gaps (Polinom.io success / warning 9.7 → 13.1, warning / danger 9.6 → 12.2; TreatMint warning / danger 2.9 → 15.0) by darkening danger (and Polinom.io success) and moving TreatMint warning to the lightest value that still passes AA (4.5:1). At AA text contrast the light-mode statuses still cannot all reach 20. Under tritanopia, Polinom.io dark success / info drops to 4.5 and light success / info to 9.9.

Info is distinct from every other status under protan/deutan in all four combinations. Under tritanopia, TreatMint dark warning / danger also drops to 6.8.

**Decision:** colour alone does **not** have to be CVD-safe (v0.27, kept in v0.28: the rebuilt Polinom.io palette improves the status pairs, but AA text contrast still pins every status into one lightness band). Instead, every status and `tone` use carries a second cue:
- **Alert, Toast, Helper / error text:** status icon plus a status word or title, always.
- **Field error state:** error icon and message, never a red border alone.
- **Badge (Dot variant), Status indicator (FBK-07):** a dot may carry status only with a visible label or a distinct icon/shape per status; otherwise it is decorative.
- **`tone` (Card, Badge, Avatar, Progress):** the four tones are decorative emphasis, never meaning. If two tones must be told apart (e.g. a legend), add a label.
- **Charts (Phase 3, interim §2.3):** status colours are not a categorical palette; chart palettes get their own CVD validation.

The check is re-run by the token build (§12) whenever a status or accent value changes.

---

## 7. Component spec template

Copy for each component when it moves to `In design`.

```markdown
## <Component name>  (`<ID>`)

**Status:** Design ☐ · Docs ☐     **Owner:** <name>     **Version:** <x.y.z>

### Platform status
| Platform | Status | Component name in code | Notes / deviations |
|---|---|---|---|
| Web (React) — Phase 1 | | | |
| Mobile (Flutter / Dart) — Phase 1 | | | |
| iOS native (SwiftUI) — Phase 2 | — | | |
| Android native (Compose) — Phase 2 | — | | |

### Purpose
One or two sentences: what problem it solves.

### When to use / When not to use
- Use when …
- Don't use when … → use <alternative> instead.

### Anatomy
Numbered list of parts (e.g. 1. Container 2. Label 3. Leading icon …).

### Variants
| Variant | Purpose | Notes |

### Sizes
| Size | Height | Padding | Typography token |

### States
Default · Hover · Focus · Active/Pressed · Disabled · Loading · Error · Selected (as applicable)

### Behavior
Interaction rules, responsive behavior, overflow/truncation, animation.

### Content guidelines
Label length, casing, tone, truncation rules, localization (text expansion, RTL).

### Accessibility
Role, keyboard map, ARIA attributes, announcements, focus management.

### Tokens used
| Property | Token |

### API (code)
One table per platform; keep prop/parameter names aligned across platforms unless a platform idiom requires otherwise.

| Prop | Web (React) | Flutter | SwiftUI | Compose | Default | Description |

### Related components
Links to siblings/alternatives.

### Changelog
| Version | Date | Change |
```

---

## 8. Audit method (populating the inventory from existing products)

1. **Pick the surfaces.** List products/apps and their highest-traffic flows. Aim for coverage, not completeness: the top ~20 screens per product usually expose ~80% of components.
2. **Capture.** Screenshot every distinct UI element; group screenshots by category (§5 headings) on a shared board.
3. **Log every instance** in the audit sheet below, including near-duplicates. Don't dedupe yet.
4. **Count and compare.** Note how many versions exist of each thing (e.g. "14 button styles, 6 shades of primary blue").
5. **Code check.** Search repos for component definitions to find implementations that look the same but aren't shared (and vice versa).
6. **Consolidate** (§9), then promote to §5 with priority scores.

### Audit log

| # | Product / Surface | Screen / URL | Element | Maps to (ID) | Divergence notes | Screenshot |
|---|---|---|---|---|---|---|
| 1 | | | | | | |

---

## 9. Consolidation log

Records decisions to merge duplicates into one canonical component.

| Canonical (ID) | Found variants | Decision | Rationale | Migration impact | Decided by / date |
|---|---|---|---|---|---|
| ACT-01 Button | _e.g. 14 styles across 3 products_ | _e.g. Reduce to 4 variants × 3 sizes_ | | _e.g. ~120 instances to update_ | |

---

## 10. Governance

### 10.1 Ownership model: hybrid

A small **core team** owns the system; **contributors** from product and platform teams build within it.

| Group | Who | Owns / does |
|---|---|---|
| **Core team** (1–3 people) | Core team (members listed by the maintainers) | Foundations and tokens (§5.0), theme layer (§2.2), token pipeline and tooling (export, lint, visual regression), specs sign-off (§7), a11y sign-off (§6), governance reviews, releases and versioning, Web (React) reference implementation |
| **Mobile team** (shared) | Platform leads for Flutter, iOS, Android (§2.1) | Mobile implementations, platform idioms, mobile parity debt; Flutter in Phase 1, native in Phase 2 |
| **Contributors** | Designers/engineers on TreatMint, Polinom.io sites, `px-refimpl` apps | Propose and build components their product needs, following the spec template and definition of done; report bugs and gaps |
| **Consumers** | Product teams | Use the system; request changes through proposals instead of forking |

**Contribution levels**
- **Fix:** bug or doc fix — any contributor, one core reviewer.
- **Extend:** new variant or prop on an existing component — contributor builds, core approves spec change.
- **New component:** proposal (below), then contributor or core builds; core signs off before `Stable`.
- **Foundations / tokens / theme:** core only (contributors may propose).

**Core team capacity:** core work is the core team's primary responsibility, not side-of-desk; if core members are shared with products, reserve an explicit allocation (e.g. ≥ 50%) so foundations and tooling don't stall.

### 10.2 Process

- **Adding a component:** open a proposal with evidence of usage (≥ 2 products or ≥ 3 screens), a draft spec (§7), and a priority score (§4). Reviewed by the design-system core team at a fixed cadence (e.g. bi-weekly).
- **Changing a component:** breaking changes require a major version bump, migration notes, and a deprecation window (e.g. 2 minor releases).
- **Deprecating:** mark `Deprecated`, name the replacement, set a removal date, and track remaining usages.
- **Parity:** design (Figma/library) and code must reach `Stable` together. In Phase 1, a component is `Stable` when Web (React) and Flutter are both `Stable`. In Phase 2, iOS and Android native are tracked per platform and do not downgrade an existing `Stable` component; a platform may be marked `Won't do` with a reason.
- **Definition of done:** spec complete · all states designed · a11y baseline (§6) met · tokens only, no hard-coded values (text uses typography roles, §5.0.1) · unit + visual regression tests in all theme × mode combinations · docs with do/don't examples · published in design library and in each platform's code package.

---

## 11. Summary dashboard

Update after each review.

| Category | Total | P0 | P1 | P2 | P3 | Stable | In progress | Not started |
|---|---|---|---|---|---|---|---|---|
| Foundations | 12 | 10 | 2 | 0 | 0 | 0 | 12 | 0 |
| Actions | 7 | 3 | 0 | 3 | 1 | 0 | 1 | 6 |
| Inputs & forms | 19 | 12 | 5 | 1 | 1 | 0 | 9 | 10 |
| Navigation | 10 | 5 | 4 | 1 | 0 | 0 | 1 | 9 |
| Feedback & status | 8 | 2 | 5 | 1 | 0 | 0 | 3 | 5 |
| Overlays | 6 | 4 | 1 | 0 | 1 | 0 | 1 | 5 |
| Data display | 13 | 5 | 3 | 2 | 3 | 0 | 4 | 9 |
| Layout & structure | 8 | 6 | 2 | 0 | 0 | 0 | 0 | 8 |
| Content & media | 8 | 3 | 1 | 1 | 3 | 0 | 1 | 7 |
| Marketing sections (Web) | 8 | 0 | 4 | 4 | 0 | 0 | 0 | 8 |
| Patterns | 8 | 1 | 3 | 3 | 1 | 0 | 0 | 8 |
| **Total** | **107** | **51** | **30** | **16** | **10** | **0** | **32** | **75** |

---

## 12. Open questions

- [x] ~~v1.0 platform sequencing~~ → Phase 1: Web (React) + Flutter; Phase 2: iOS + Android native.
- [x] ~~Flutter after Phase 2~~ → Flutter remains for some products; three mobile implementations are maintained (see §2.1).
- [x] ~~Product → platform mapping~~ → TreatMint: Flutter; Polinom.io `px-refimpl-ios`: iOS native; Polinom.io `px-refimpl-android`: Android native (see §2.1).
- [x] ~~Web (React) consumer~~ → Polinom.io landing page (`px-landing-page`) and TreatMint product page (`treatmint.polinom.io`).
- [x] ~~TreatMint brand expression~~ → Distinct color palette; theme layer required (see §2.2).
- [x] ~~TreatMint typography~~ → Same as Polinom.io initially; may differ in a later iteration. Typography is routed through the theme layer from day one (see §2.2).
- [x] ~~TreatMint typography divergence timing~~ → Decided after the TreatMint initial prototype is finished (see §2.2).
- [ ] At prototype review: confirm whether TreatMint typography diverges; if yes, plan font licensing per platform and refresh TreatMint visual regression baselines.
- [x] ~~Mobile stack convergence~~ → No. Flutter, iOS native and Android native remain separate long-term (see §2.1).
- [x] ~~Mobile staffing~~ → Shared mobile team across Flutter, iOS native and Android native, with a platform lead per stack (see §2.1).
- [x] ~~Phase 2 trigger~~ → **Decided 5 Nov 2026 (v0.33):** Phase 2 starts when every Phase 1 P0 component is `Stable` on Web and Flutter. Native work begins from a stable API, so it never chases Web/Flutter changes; P1 components join the native backlog as they reach `Stable`.
- [x] ~~Single theme or multi-brand~~ → Multi-brand: Polinom.io and TreatMint themes (see §2.2).
- [x] ~~Dark mode~~ → Required: light and dark for both Polinom.io and TreatMint themes (see §2.2).
- [x] ~~Headless library~~ → No. Web components are built in-house (see §2.3).
- [x] ~~Low-level utility packages~~ → Not allowed; prefer native browser capabilities (see §2.3).
- [x] ~~Browser support matrix~~ → Last 2 major versions of Chrome, Edge, Firefox and Safari, desktop and mobile (see §2.3).
- [ ] Validate against site analytics once the landing pages are live: share of visitors on iOS versions older than the last 2 (they cannot get a newer Safari without an OS update), Samsung Internet, and in-app webviews. If material, extend the matrix and add the fallbacks from §2.3.
- [x] ~~Ownership model~~ → Hybrid: core team + federated contributors, shared mobile team for mobile (see §10.1).
- [x] ~~Core team and document owner~~ → Core team and a named document owner (4 Nov 2026; contact details are internal). Foundations (FND-01…12) are owned by the core team, per §10.1.
- [x] ~~Data-viz scope~~ → Phase 3, using third-party charting libraries wrapped by the system (see §2.1, §2.3).
- [ ] Phase 3: charting library per platform (Web, Flutter, iOS, Android) and which products need charts first.
- [x] ~~Polinom.io palette~~ → Solarized, high-contrast light and dark, exact values plus AA contrast additions for text and labels (see §2.2).
- [x] ~~Colour palette refactor~~ → **v0.26 (4 Nov 2026):** four primitive categories with the same slot names in both brands: Neutrals, Brand, Accents (actions and emphasis), Status. Polinom.io: brand primary violet, secondary orange; accents cyan (primary) and magenta (secondary); 32 → 23 colours. TreatMint: secondary Lavender #8C7BC8. Removed: unused raw Solarized accents, the four term colours, and the duplicate hover/pressed fill tokens (state layers instead). Renamed `color-brand-accent` → `color-brand-primary`, `color-brand-accent-subtle` → `color-brand-tint`. 308 pairs pass AA (§2.2, FND-01).
- [x] ~~Colour rebuild~~ → **v0.28 (5 Nov 2026):** all colour tokens and docs dropped and rebuilt. Structure kept (Neutrals, Brand, Accents, Status, same slots in both brands); TreatMint values kept. Polinom.io: brand blue / orange / cyan (new slot `brand-tertiary`), accents magenta / violet / teal / clay (accent slots `-tertiary` and `-quaternary` added; TreatMint repeats its two), neutrals from the logo ground, new status colours. Links and focus in Polinom.io use the blue fill shades. `tone` gains `tertiary` and `quaternary`. 380 pairs pass AA (§2.2, §6.1).
- [x] ~~Polinom.io brand primary~~ → **v0.29 (5 Nov 2026): violet #6C71C4**, matching the logo's top dot (no logo recolour). Compared on components against blue (current v0.28) and orange: blue put primary actions in the info family; orange made the primary and danger buttons nearly identical in dark mode. Secondary accent moved from violet to blue.
- [x] ~~Term colours~~ → Removed (v0.26). The four terms stay in the copy; Card, Badge, Avatar and Progress take `tone="primary" | "secondary"` (breaking change to their `term` prop; all four are `In build`, no released consumers).
- [x] ~~Font families~~ → Atkinson Hyperlegible Next for all text roles; Hack for code only (see §5.0.1).
- [x] ~~Icon set~~ → Phosphor, copied as SVG and generated per platform by the token build; no per-platform icon packages (FND-10).
- [x] ~~Product name~~ → **TreatMint** is the official spelling; token and file identifiers stay lowercase (`treatmint-*`).
- [x] ~~Logos~~ → Official Polinom.io logo: 12 delivered files (5 Nov 2026): horizontal and stacked lockups for dark and light grounds, mono and mono reversed, icon and light-tile icon, favicon and light-tile favicon, app icon and light app icon. The same 12 files replaced the 4 earlier Polinom.io lockups in the design system's `assets/Logos/` on 5 Nov 2026, with the brand book's Logo section, the Logos card and the asset README updated (CNT-04). TreatMint's 11 Direction B files replaced the v1.1 lockups there on 4 Nov 2026.
- [x] ~~Polinom.io logo colours~~ → Recoloured 4 Nov 2026 (v0.26) to the new palette at exact values: dots violet #6C71C4, orange #CB4B16, cyan #2AA198; wordmark full stop orange. Geometry and wordmark unchanged. On the dark tile the violet and orange dots reach about 3:1. Earlier versions and the proposal folders (including the blue / orange / cyan and blue / orange / yellow tests of 5 Nov 2026) were deleted on 5 Nov 2026; violet / orange / cyan stays official.
- [x] ~~TreatMint logo direction~~ → **Direction B, geometric leaf** (approved 4 Nov 2026): Teal #143C38, Deep mint #009C7D, Mist #DCEBE4; one 8-unit gap at every size; single-colour wordmark in Plus Jakarta Sans 700 (wordmark only). 11 delivered files.
- [x] ~~Upload the Direction B logo files~~ → All 11 are in the design system under `assets/Logos/` (4 Nov 2026); the v1.1 lockups were removed from the Logos group.
- [x] ~~Update the TreatMint official logo artifact (v1.1) to Direction B~~ → Done: the TreatMint Logo artifact shows Direction B (approved 4 Nov 2026, replaces v1.1); confirmed 5 Nov 2026.
- [x] ~~TreatMint clear space~~ → Half the leaf height (½L) on every side, measured from the visible logo; built into the lockup and icon files' canvas (re-exported 4 Nov 2026, artwork unchanged, delivered originals kept). App icons need none.
- [x] ~~Direction B leaf gap and minimum size~~ → Checked on screen 4 Nov 2026: the gap is clean from 32px (1×) and 16px (2×), soft but visible at 16px (1×); ground vs Deep mint is 3.5:1 on white and Teal, 4.8:1 on Night; at 160px the 11.6px slash stays 12.5% of the leaf. Minimum widths: horizontal 150px, stacked 130px, icon with clear space 48px, favicon 16px. Added `treatmint-favicon.svg` / `-dark.svg` (the delivered icons, tight canvas) for slots under 48px.
- [x] ~~Polinom.io Monaspace Neon lockup~~ → Not needed as a separate file: every lockup in the 5 Nov 2026 set uses the Monaspace Neon NF 1.400 wordmark, converted to outlines.
- [x] ~~Polinom.io logo gaps~~ → Closed 5 Nov 2026: stacked-on-light, mono and mono reversed added. Minimum widths: horizontal 160px, stacked 110px, icon with clear space 48px, favicon 16px. Clear space is ¼ of the tile on every side, built into the lockup and icon files; favicons and app icons have none.
- [x] ~~Upload the 12 Polinom.io logo files to `assets/Logos/`~~ → Done 5 Nov 2026 (design system version 53); the 4 earlier lockups were removed from the Logos group.
- [x] ~~Earlier "Polinom.io Design System" (27 Oct)~~ → Brand idea (four terms), term colors, house voice and 14 components moved into the current system; components rebuilt on current tokens, `In build` on Web only (§5.11).
- [x] ~~TreatMint theme colors~~ → Rebuilt from the logo v1.1 palette (v0.23), then moved to the Direction B palette (v0.24): primitives renamed to `treatmint-teal`, `treatmint-deep-mint`, `treatmint-mist` (old `treatmint-mist` → `treatmint-mist-pale`, success shades → `treatmint-cyan-text-*`), plus `treatmint-deep-mint-text-dark` for dark-mode links and focus; every pair passes AA in all four theme × mode combinations (FND-01).
- [x] ~~Code status of migrated components~~ → Keep the lowest-status rule (§3.1): Code reads `—` until Flutter starts; Web progress is tracked in §5.11.
- [x] ~~14 migrated components vs 18 `In build` rows~~ → Field covers six rows; mapping in §5.11.
- [x] ~~Data table on Web~~ → Basic variant only, as a static content table; app-heavy variants stay deferred on Web (DSP-02).
- [x] ~~Document name~~ → Renamed to `polinom-design-system-spec.md` (v0.24).
- [x] ~~TreatMint default for Card and Progress~~ → Resolved by v0.26: term colours are gone; the default `tone` is `primary` (`color-accent-primary`, Deep mint shades in TreatMint).
- [x] ~~Polinom.io secondary button~~ → Outlined with `color-border-control`, as the original polinom.io site CSS already did (ACT-01).
- [x] ~~Light-mode status colour-blind gaps~~ → **Fixed 5 Nov 2026 (v0.32):** no status pair is under 10 any more in either theme or mode. Open side effect: TreatMint light warning #9E5600 vs the gold tone #726418 is 1.2 under protan (5.0 deutan) and Polinom.io light danger #9D263D vs clay is 7.1 under protan; allowed by §6.1 (tones never sit next to a status message), watch in component previews.
- [x] ~~`tone` count (four vs two)~~ → **Kept at four (5 Nov 2026, v0.31):** TreatMint tertiary and quaternary are now their own colours (gold #726418 / #CFB52B, orchid #B03B7D / #D685B3) instead of aliases. Coral was tried for quaternary and rejected: it is ΔE00 4.0 (light) and 6.1 (dark) from danger. Orchid is the best fourth hue against mint, lavender, gold and the four statuses (worst pair ≥ 8.4); it stays under 10 against mint and lavender under protan/deutan, covered by the §6.1 label rule. Polinom.io dark magenta / teal (8.7) and teal / clay (9.7) are unchanged.
- [x] ~~Polinom.io success vs danger colour-blind safety~~ → **Decided 5 Nov 2026 (v0.27, kept through v0.29):** colour alone does not have to be CVD-safe; every status and `tone` use carries an icon, word or label (§6.1). The v0.28 rebuild separated Polinom.io success and danger in lightness (16.1 light, 16.7 dark under protan/deutan), but light-mode success / warning and warning / danger stay under 10, and the magenta / teal and teal / clay `tone` pairs fall under 10 in dark mode; TreatMint light warning / danger stays confusable (2.9). Current figures in §6.1.
- [x] ~~Token naming in platform exports~~ → **v0.30 (5 Nov 2026):** neither form everywhere. Hyphenated source names are canonical and used in this document; each export converts them to its platform's convention (CSS custom properties, lowerCamelCase in Dart, Swift and Kotlin), flat, with primitives in their own namespace and collisions or reserved words failing the build (§2.2, Token naming).
- [x] ~~Motion tokens (FND-08)~~ → **v0.27 (5 Nov 2026):** the design-system format has no motion category, so motion lives in a sidecar DTCG file, `motion.tokens.json` (`tokens/motion.tokens.json`), merged with `tokens.json` by the token build. Values unchanged from the README guidance. Shared across themes and modes. The design system README's Motion section points to it (5 Nov 2026).
- [x] ~~Rename `polinom` theme ids to `px`~~ → **Done 5 Nov 2026 (v0.43):** design system `tokens.json` theme ids `px-light|dark`; web `data-theme="px"`; Dart `PxDsBrand.px`, `PxDsPrimitives.px`, `PxDsColors.pxLight|pxDark`. Builds and verifiers re-run green; Iconography and Logos previews and the README updated.
- [ ] Remaining pre-v0.38 `polinom` names: 12 logo files (`polinom-logo-horizontal.svg` …), the design system page's bundle namespace `window.Polinom` and CSS class prefix `pl-`. Logo renames mean re-uploading the assets; do them with the repo migration.
- [ ] Token build: **Node, no dependencies (v0.45).** `node tools/build.mjs` runs every step; `--check` fails when a committed generated file is out of date (the CI drift check). Done: web CSS (`build-web-css.mjs`, 12 cascade cases verified), Dart (`build-dart.mjs` → `tokens.g.dart`, `PxDs…` types, verified by `verify-dart.mjs`; not yet compiled in a Flutter project), merge of `motion.tokens.json`, naming, completeness and alias checks (missing and cyclic aliases fail), CVD report (`cvd-check.mjs`, informational per §6.1), contrast check (`contrast-check.mjs`, v0.46: 356 pairs from `tokens/contrast-pairs.json` across the four themes, WCAG 2.2 AA, fails the build; all pass today, tightest TreatMint light warning text on its fill at 4.50:1). Outputs are byte-identical to the earlier Python scripts apart from the header line. Remaining: Phosphor icon generation, copying fonts into each package, Swift and Kotlin exports (Phase 2).
- [x] ~~Component inventory review (6 Nov 2026, v0.53)~~ → Ten requested components checked against §5. Nine were already there: tab bar (NAV-03 Tabs, P0; on mobile also NAV-07 Bottom navigation, P2), summary figures (DSP-09 Stat / KPI, P2), table (DSP-02 Data table, P1), dialog (OVL-01 Modal / Dialog, P0), switch (INP-07, P0), radio group (INP-06 Radio, Group variant, P0), calendar (DSP-12, P2), slider (INP-08, P2), time picker (INP-10, P2); their priorities are unchanged. One was missing and is added at P0: **INP-19 Body outline**, a front/back body figure for picking or showing body regions (TreatMint, Flutter only). Accessibility rules for its spec (§7): every region has a name ("Left knee") and is a keyboard- and screen-reader-operable toggle with a selected state; selection is never shown by colour alone (fill pattern or outline weight plus the region list); offer the same choice as a checkbox list for anyone who can't use the figure. **Settled 6 Nov 2026 (v0.54):** (1) Usage: TreatMint's Log pain view (select), Pain history and Treatments section (display), which meets the inclusion rule (§2.3: ≥ 3 distinct screens). (2) Regions are named by side, area and face, e.g. "Left knee, front"; the full region list is part of the spec. (3) The artwork is a simple, custom-made body form owned by the system (no third-party licence): one outline per face, each region a separate vector shape, all colours from semantic tokens so it works in the four theme × mode combinations. (4) As a P0 it must be `Stable` on Flutter before Phase 2 starts; the delay to native work is accepted.
- [x] ~~Priorities of the TreatMint list (6 Nov 2026, v0.55)~~ → All components from the 6 Nov review are **P0**: NAV-03 Tabs and NAV-07 Bottom navigation (tab bar), DSP-09 Stat / KPI, DSP-02 Data table, OVL-01 Modal / Dialog, INP-07 Switch, INP-06 Radio, DSP-12 Calendar, INP-08 Slider, INP-10 Time picker, INP-19 Body outline (raised: NAV-07, DSP-09, DSP-12, INP-08, INP-10 from P2; DSP-02 from P1). P0 is driven by TreatMint, so Web scope follows §2.1: Calendar, Time picker and Slider are `Won't do` on Web until a web consumer exists, and Data table stays Basic only on Web; a `Won't do` platform does not block the Phase 2 trigger (§10 parity). Phase 2 now waits for 51 P0 components; the delay to native work is accepted. INP-19 spec draft (v0.1.0): `docs/specs/body-outline.md` in `polinom-io/px-ds` (PR #13), the source from now on; component specs live in the repo, the overall spec stays here until Phase 1 is `Stable`.
- [x] ~~Where the spec lives~~ → **In the repo (6 Nov 2026, v0.56)**, ahead of the earlier plan to wait for Phase 1 `Stable`: `docs/spec.md` (renamed from `polinom-design-system-spec.md`, which also retires the old `polinom` file name) and component specs in `docs/specs/`. Internal contact details are kept out because the repo is public.
- [ ] First Flutter widgets → **PR #6 (6 Nov 2026, v0.52), CI green, ready for review:** `PxDsButton`, `PxDsTextField`, `PxDsCard`, `PxDsAlert`, `PxDsIcon` (chosen as the controls every screen needs; no TreatMint prototype yet). Icons: `assets/icons/` holds the 35 Phosphor 2.1.1 SVGs (from `@phosphor-icons/core`) as the single source; `tools/icons.mjs` generates Dart paths, checked by redrawing every icon. CI renders a widget gallery in the four themes with the real fonts (reviewed visually: correct colours, icons, true font weights; fixed an indent of helper/error text). The gallery is not yet a committed baseline.
- [x] ~~Flutter package `px_ds`~~ → **Released in 0.1.1 (5 Nov 2026, v0.51; PR #4/#5):** tokens as `ThemeExtension`s plus bundled ttf fonts (variable Atkinson declared per weight to avoid synthetic bold; text roles use `package: 'px_ds'`). First real compile of the generated Dart: `flutter analyze` clean on Flutter 3.47.9 / Dart 3.13.7; 9 tests pass. `tools/build.mjs` now copies the ttf into the package and checks it byte for byte. Widgets next, ordered by TreatMint's screens. **Releases:** `v0.1.0` (web package) and `v0.1.1` (web + Flutter, both versions 0.1.1) published 5 Nov 2026; `@polinom-io/px-ds-react@0.1.1` is on GitHub Packages and `px_ds` installs from the `v0.1.1` tag. Tags are pushed by a maintainer.
- [x] ~~Web package `@polinom-io/px-ds-react`~~ → **Merged 5 Nov 2026 (PR #2, v0.49); `main` ruleset requires the Tokens and Web package checks:** the 14 components rewritten in TypeScript (class prefix `px-`), Astro rules from §2.3 built in (no context, no browser APIs during render, `useId`), 87 tests (server render without DOM, hydration per island, axe-core, behaviour, stylesheet checks). Fixed on the way: Progress fill had no colour. Correction to v0.46: pnpm 12 ignores credentials in a project `.npmrc`, so the token lives in `~/.npmrc` or comes from CI. Still open per component: the states each README lists as not built; Astro playground with visual regression; publish workflow.
- [x] ~~Repo created~~ → **5 Nov 2026 (v0.47):** `polinom-io/px-ds` is live and public, MIT licensed. `main` holds the tokens, the Node build, fonts, README, workspace `package.json` (Node ≥22, pnpm 12.15.0) and CI (PR #1, merged): every pull request and push to `main` runs `node tools/build.mjs --check`, green on Node 26.13.0. Still to do on GitHub: make the "Tokens (build, verify, contrast)" check required for `main`.
- [x] ~~Repo starter files~~ → **v0.46:** `.gitignore` (macOS, editors, Node/pnpm, Astro, Playwright, Flutter/Dart, Xcode/SwiftPM, Android/Gradle; generated token files deliberately tracked), `.npmrc` (`@polinom-io` on GitHub Packages, token from `NODE_AUTH_TOKEN`, `engine-strict`, `save-exact`), `.nvmrc` = `26` (Node 26 "Lithium", the current LTS since 28 Oct 2026; the build scripts also run on Node 22). TTF fonts added beside the woff2 files in `assets/fonts/`: Atkinson Hyperlegible Next 2.001 variable roman and italic, Hack 3.003 regular and bold, from the upstream releases and checked to be the same fonts (same version, same glyphs) as the design system's woff2.
- [x] ~~Build tooling language~~ → **Node (5 Nov 2026, v0.45).** The web package already needs Node, so the repo runs one toolchain; Python scripts retired. Plain ES modules, no packages to install; the repo pins Node 26 LTS in `.nvmrc`, and the scripts also run on Node 22.
- [x] ~~Where tokens are edited~~ → **In the repo (5 Nov 2026, v0.45).** `tokens/tokens.json` and `tokens/motion.tokens.json` in `polinom-io/px-ds` are the only editable source; changes go through pull requests and CI (naming, completeness, contrast, CVD report). The design system page becomes read-only, synced from the repo once it exists. If Figma joins the process, its variables and text and effect styles are generated from the repo and imported one way; designers propose changes, they do not edit tokens in Figma.
- [x] ~~Polinom.io logo dots at small sizes~~ → Checked 5 Nov 2026 (rendered at 1×): on the dark tile violet is 2.9:1 and orange 2.8:1, separated from the curve by a ring in the tile colour. Below 48px the full mark loses its dots, so a favicon cut (no axis line, curve 9 units, dots 10 units) keeps all three legible at 16px. On the light tile the bottom dot uses `accent-tertiary-light` #00716F, because exact cyan is 2.6:1 there.
- [x] ~~Polinom.io logo colours on palette tokens~~ → 5 Nov 2026: every logo colour is a v0.29 token except the print ink #111111. Tile `neutral-850`, ground `neutral-900`, name `neutral-100` on dark and `neutral-850` on light, “.io” and curves `neutral-400` / `neutral-600`, light tile `neutral-100`, light ground `neutral-50`, dots `brand-primary` / `-secondary` / `-tertiary`, light-tile bottom dot `accent-tertiary-light`. The name on dark grounds is brighter than before (12.5:1).
