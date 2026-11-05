# Tabs

Tabs switch between views of the same content. Spec: NAV-03, line variant.

```jsx
import { Tabs } from '@polinom-io/px-ds-react';

<Tabs label="Engagement" tabs={[{ label: "Overview", content: <p>…</p> }, { label: "Process", content: <p>…</p> }]} />
```

- **The consumer provides** `label` (names the tab list for screen readers) and `tabs`, each a `label` plus `content`.
- **Follows the WAI-ARIA tabs pattern:**
  - `tablist`, `tab` and `tabpanel` roles.
  - `aria-selected` and `aria-controls` on each tab.
  - Roving `tabindex`: one Tab stop for the whole list.
  - Left/Right arrows, Home and End move between tabs.
- **Selected tab:** `color-text-default` with a 2px `color-text-link` underline. Unselected tabs are `color-text-muted`.
- **When not to use:** for site navigation, use links in the Header.
- **In Astro:** Interactive: `client:visible`. The server HTML shows the first tab, so content is readable before hydration. From an .astro file, pass `content` as strings; React elements need a React parent.
