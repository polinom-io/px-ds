# Button

Button triggers an action, or, given `href`, navigates with a button's look. Use `primary` for the one main action per view, `secondary` and `ghost` for supporting actions, and `danger` for destructive ones behind a confirmation (PAT-04). Spec: ACT-01.

```jsx
import { Button } from '@polinom-io/px-ds-react';

<Button variant="primary" size="lg" onClick={start}>Start a project</Button>
<Button href="#contact" variant="secondary">See our approach</Button>
```

- **Button or link:** an action (submit, open, toggle, delete) renders `<button>`; navigation (another page, an anchor, a download) passes `href` and renders `<a>`, so it keeps native link behaviour: open in a new tab, copy the URL, and the link role for screen readers. Never use `onClick` to navigate.
- **Links:** have no disabled state and no `type` (TypeScript rejects both). With `target="_blank"`, say so in the label or with a labelled icon ("Opens in a new tab"), so the change of context isn't a surprise.
- **Native attributes** pass through to the element (`aria-*`, `name`, `value`, `form`, `id`, `data-*`, `download`, `target`, `rel`…). A consumer `className` is added after the design system classes. `ref` reaches the rendered `<button>` or `<a>`.

- **The consumer provides** the label (a verb, sentence case: "Save changes", not "OK"), `onClick`, and `type="submit"` inside forms.
- **Variants:** `primary`: `color-action-primary-bg` fill. In Polinom.io this is a violet shade (`brand-primary-fill-light|dark`), because exact brand violet can't carry a label at 4.5:1. `secondary`: outlined, with a `color-border-control` edge on `color-action-secondary-bg`. The outline makes the button shape visible in Polinom.io, where the secondary fill is only about 1.1:1 against the page. `ghost`: no fill until hover.
- `danger`: `color-action-destructive-bg` fill.
- **Sizes:** `sm` / `md` / `lg` follow `size-control-*` (32 / 40 / 48px). Use `lg` on touch screens; `sm` needs a hit area padded to `size-touch-min`.
- **States:**
- Hover and press add a state layer of the label color (`opacity-state-hover` / `-pressed`). There are no separate hover or pressed fill tokens (removed in v0.26).
- Focus shows the 2px `color-focus-ring`.
- Disabled uses `opacity-disabled`.
- **Placement:** never put a primary or danger button on `color-surface-sunken`.
- **Not built yet:** the Loading state and leading/trailing icons (#40), and `aria-disabled` (#39).
- **In Astro:** No directive for a link (`href`) or a submit button. With `onClick`, render it inside a React island.
