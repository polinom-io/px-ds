import { useEffect, useId, useRef, type ReactNode } from 'react';
import { Icon } from '../../internal/Icon.js';

export interface ModalProps {
  open: boolean;
  /** Called when the dialog closes (close button, Esc, or form method="dialog"). */
  onClose?: () => void;
  /** Phrase it as the question or the task. */
  title: string;
  children: ReactNode;
  /** Actions, safe one first. */
  footer?: ReactNode;
}

/**
 * Modal (OVL-01): native <dialog> opened with showModal(), so the browser provides the top layer,
 * focus trap, Esc and the inert background. Interactive: render it inside a React island
 * (client:load) together with whatever sets `open`.
 */
export function Modal({ open, onClose, title, children, footer }: ModalProps) {
  const ref = useRef<HTMLDialogElement>(null);
  const titleId = useId();
  useEffect(() => {
    const dialog = ref.current;
    if (!dialog) return;
    if (open && !dialog.open) dialog.showModal();
    if (!open && dialog.open) dialog.close();
  }, [open]);
  return (
    <dialog ref={ref} className="px-modal" aria-labelledby={titleId} onClose={onClose}>
      <div className="px-modal__head">
        <h2 id={titleId} className="px-modal__title">{title}</h2>
        <button type="button" className="px-iconbtn" aria-label="Close" onClick={() => ref.current?.close()}>
          <Icon name="x" size={20} />
        </button>
      </div>
      <div className="px-modal__body">{children}</div>
      {footer ? <div className="px-modal__foot">{footer}</div> : null}
    </dialog>
  );
}
