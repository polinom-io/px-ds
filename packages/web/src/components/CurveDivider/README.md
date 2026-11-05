# CurveDivider

CurveDivider is the Polinom.io section break: a rising curve plotted against a flat baseline. It is a brand element, not a generic divider.

```jsx
import { CurveDivider } from '@polinom-io/px-ds-react';

<CurveDivider ariaLabel="Growth curve, rising left to right" />
```

- **Colors:** the curve is `color-brand-primary` (violet). The midpoint dot is `color-brand-tertiary` (cyan) and the endpoint dot `color-brand-secondary` (orange): the three Polinom.io brand colours, the same as the logo dots. The baseline is `color-border-subtle`.
- **Accessibility:** pass `ariaLabel` only when the curve means something on that page. Otherwise it is hidden from screen readers.
- **Where to use:** marketing pages only, at most once per page (between the hero and the content). Use a plain hairline (`color-border-subtle`) everywhere else.
- **Never in TreatMint.**
- **In Astro:** No directive needed.
