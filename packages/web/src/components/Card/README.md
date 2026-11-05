# Card

Card groups related content on `color-surface-default`, marked by a 3px top edge in an accent colour. Spec: DSP-01.

```jsx
import { Card } from '@polinom-io/px-ds-react';

<Card tone="secondary" exponent="x⁰" title="Execution & delivery">The constant term — always present.</Card>
```

- **The consumer provides** `title`, the body, an optional `exponent` chip (code font, accent colour, such as "x³" or "// solved for") and `tone`. Use `as` to set the heading level (default `h3`).
- **Tone:** `primary` (default), `secondary`, `tertiary` or `quaternary`: `color-accent-*`, which in Polinom.io are magenta, blue, teal and clay. In TreatMint they are deep mint, lavender, gold and orchid. All pass 4.5:1 as text on every surface in all four themes.
- **The accent edge:**
  - The coloured top edge is decoration that groups related cards. It never encodes status, and never a meaning that isn't also in the text.
  - Never use a left border, and never add a second accent.
  - There is no shadow at rest. Elevation is for floating things.
- **Changed in v0.28:** four tones instead of two. (v0.26: `tone` replaced `term`; the four terms stay in the copy, not in colour.)
- **Not built yet:** the interactive and media variants.
- **In Astro:** No directive needed.
