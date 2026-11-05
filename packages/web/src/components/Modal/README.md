# Modal

Modal is a dialog that blocks the page until the person responds. Spec: OVL-01, including the Alert dialog variant.

```jsx
import { Modal } from '@polinom-io/px-ds-react';

<Modal open={open} onClose={() => setOpen(false)} title="Delete this project?"
  footer={<><Button variant="ghost">Keep project</Button><Button variant="danger">Delete project</Button></>}>
  This removes the project and its files. You can't undo this.
</Modal>
```

- **The consumer provides** `open`, `onClose`, a `title` phrased as the question, and the body. The `footer` holds the actions, with the safe one first.
- **Native `<dialog>` with `showModal()`:** the browser handles the top layer, the focus trap, Esc to close, the inert background and returning focus.
- **Surfaces:**
  - The panel is `color-surface-overlay` with `shadow-4`, at `radius-xl`.
  - The backdrop is `color-scrim`.
- **Closing:** the close button is an icon button with `aria-label="Close"`.
- **In Astro:** Interactive: render it inside a React island (`client:load`) together with the button or state that sets `open`. `onClose` is a function, so it cannot be passed from an .astro file.
