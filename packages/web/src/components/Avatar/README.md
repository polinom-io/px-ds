# Avatar

Avatar shows a person or team as initials. Spec: DSP-04, initials only.

```jsx
import { Avatar } from '@polinom-io/px-ds-react';

<Avatar initials="ME" name="Mario Espinoza" size="lg" />
```

- **The consumer provides** 1–2 `initials`. Add `name` when the avatar stands alone, so it is announced. Leave it out when the name is printed next to it.
- **Colour:** the fill is the accent for `tone` with `color-surface-page` text (4.5:1 or more in all four themes). Tones: `primary` (default), `secondary`, `tertiary` or `quaternary`: `color-accent-*`, which in Polinom.io are magenta, blue, teal and clay. In TreatMint they are deep mint, lavender, gold and orchid.
- **Sizes:** `sm` / `md` / `lg` are 24 / 32 / 40px.
- **Changed in v0.28:** four tones instead of two.
- **Not built yet:** the image and status variants.
- **In Astro:** No directive needed.
