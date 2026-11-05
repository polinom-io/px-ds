# Switch

Switch turns a setting on or off immediately, with no Save button. Spec: INP-07.

```jsx
import { Switch } from '@polinom-io/px-ds-react';

<Switch label="Email updates" defaultChecked />
```

- **The consumer provides** `label` and `name`, and applies the change as soon as the switch changes.
- **Markup:** a native checkbox with `role="switch"`, so screen readers announce "on/off".
- **Visual:**
  - Off: the track is `color-surface-sunken`, outlined in `color-border-control`.
  - On: the track takes `color-action-primary-bg`, and the thumb `color-action-primary-fg`.
- **When not to use it:** if the change needs confirming, use Checkbox inside a form instead.
- **In Astro:** No directive when it only submits with a form. With `onChange`, render it inside a React island.
