# Checkbox

Checkbox is a native checkbox with its label. Spec: INP-05.

```jsx
import { Checkbox } from '@polinom-io/px-ds-react';

<Checkbox label="I agree to the privacy policy" />
```

- **The consumer provides** `label` and `name`. For several related options, wrap them in a `<fieldset>` with a `<legend>`.
- **Styling:** the native input, tinted with `accent-color: var(--color-action-primary-bg)`. Keyboard and screen-reader behavior come free.
- **Hit area:** the whole row is clickable and at least `size-touch-min` tall.
- **Not built yet:** the Indeterminate and Error states.
- **In Astro:** No directive needed.
