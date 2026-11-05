# Table

Table shows rows of comparable data. Spec: DSP-02, basic variant only.

```jsx
import { Table } from '@polinom-io/px-ds-react';

<Table caption="How the terms are weighted" columns={["Term", "Degree"]} rows={[["Strategy", "x³"]]} />
```

- **The consumer provides** `caption`, `columns` and `rows`.
- **Accessibility:**
  - `caption` names the table and its scroll region.
  - Header cells use `scope="col"`.
  - On narrow screens the wrapper scrolls and can be reached with Tab.
- **Not built yet:** sorting, selection, expandable rows and density options. Build them when an app consumer needs them (§2.1).
- **In Astro:** No directive needed.
