# Field

Field is a labelled form control: a text input, email, textarea or select, with optional helper and error text. Spec: INP-16, covering INP-01/02/03 controls, INP-14 Label and INP-15 Helper/error text.

```jsx
import { Field } from '@polinom-io/px-ds-react';

<Field label="Work email" type="email" required helper="We reply within one business day." />
<Field label="Company" error="Enter your company name." />
```

- **The consumer provides** `label` (always: never rely on the placeholder alone), `name`, and validation. Field only displays `error`.
- **Wiring:** the label is tied to the control with a generated `id`. Helper and error text are linked through `aria-describedby`, and `error` sets `aria-invalid`.
- **Error state:** a 2px `color-feedback-danger-fg` border, plus an icon and words. Color is never the only signal.
- **Select** is the native `<select>`, per the spec's native-first rule.
- **Additions over the source component:** `helper`, `error`, `required`, `name` and `disabled` were added to meet INP-15 and §6.
- **In Astro:** No directive needed: the form works without JavaScript. Ids come from `useId`, so a hydrated Field matches its server HTML.
