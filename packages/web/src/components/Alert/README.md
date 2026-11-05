# Alert

Alert is an inline status message. Spec: FBK-01.

```jsx
import { Alert } from '@polinom-io/px-ds-react';

<Alert tone="warning" title="Spanish copy needs review">First-pass translation, not yet reviewed.</Alert>
```

- **The consumer provides** `tone` and a `title` that states what happened. Optional body text says what to do next.
- **Icon:** every tone has a Phosphor icon (`info`, `check-circle`, `warning`, `x-circle`) and a title, so color is never the only signal.
- **Colors:**
  - The fill is `color-feedback-*-bg`.
  - The icon and title are `color-feedback-*-fg`.
  - The body is `color-text-default`.
- **Announcement:** warning and danger use `role="alert"`, which announces immediately. Info and success use `role="status"`.
- **Keep apart from accents:** status colours and the accent tones (`color-accent-*`) never stand in for each other.
- **Not built yet:** the dismissible variant.
- **In Astro:** No directive needed.
