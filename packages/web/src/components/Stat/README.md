# Stat

Stat shows one figure with its label. Spec: DSP-09.

```jsx
import { Stat } from '@polinom-io/px-ds-react';

<Stat value="4" label="terms in every engagement" />
```

- **The consumer provides** a real `value` and a `label` that reads as a sentence with it.
- **No invented numbers:** use structural facts ("4 terms", "1 point of contact"), never made-up track-record figures like "50+ clients".
- **Type:** the figure is `display-md` in `color-text-link`. The label is `body-sm` in `color-text-muted`.
- **In Astro:** No directive needed.
