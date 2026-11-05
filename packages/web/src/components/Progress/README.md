# Progress

Progress shows how far a known task has gone. Spec: FBK-04, determinate only.

```jsx
import { Progress } from '@polinom-io/px-ds-react';

<Progress label="Design" value={60} tone="secondary" />
```

- **The consumer provides** `label` and `value` (0–100).
- **Colour:** `tone` sets the fill: `primary` (default), `secondary`, `tertiary` or `quaternary`: `color-accent-*`, which in Polinom.io are magenta, blue, teal and clay. In TreatMint they are deep mint, lavender, gold and orchid. All reach at least 3:1 against the sunken track in all four themes.
- **Accessibility:** it has `role="progressbar"` with `aria-valuenow`, and is labelled by the visible label. The percentage is printed, so the fill colour carries no meaning on its own.
- **Changed in v0.28:** four tones instead of two.
- **Not built yet:** the indeterminate variant. Use Spinner for unknown durations (PAT-02).
- **In Astro:** No directive needed for a fixed value. A value that changes needs a React island.
