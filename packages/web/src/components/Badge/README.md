# Badge

Badge is a short label in one of the four accent tones. Spec: FBK-06.

```jsx
import { Badge } from '@polinom-io/px-ds-react';

<Badge tone="secondary" variant="soft">x¹ Data</Badge>
```

- **The consumer provides** one or two words and a `tone`: `primary` (default), `secondary`, `tertiary` or `quaternary`: `color-accent-*`, which in Polinom.io are magenta, blue, teal and clay. In TreatMint they are deep mint, lavender, gold and orchid.
- **Variants:**
  - `soft`: accent-coloured text and edge on `color-surface-sunken`.
  - `outline`: transparent fill.
  - `solid`: accent fill with `color-surface-page` text.

  Every variant meets 4.5:1 in all four themes.
- **Not for status:** use Alert or the feedback colours for status, never an accent badge.
- **Changed in v0.28:** four tones instead of two.
- **In Astro:** No directive needed.
