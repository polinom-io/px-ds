import type { MouseEventHandler, ReactNode } from 'react';
import { cx } from '../../internal/shared.js';

export interface ButtonProps {
  /** primary: the one main action per view · secondary: outlined · ghost: no fill until hover · danger: destructive. */
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger';
  /** Heights follow size-control-sm | md | lg (32 / 40 / 48px). */
  size?: 'sm' | 'md' | 'lg';
  type?: 'button' | 'submit' | 'reset';
  disabled?: boolean;
  /** Only when Button renders inside another React tree; a function cannot cross an Astro island boundary. */
  onClick?: MouseEventHandler<HTMLButtonElement>;
  children: ReactNode;
}

/** Button (ACT-01). No client JavaScript needed unless onClick is used inside a React island. */
export function Button({ variant = 'primary', size = 'md', type = 'button', disabled, onClick, children }: ButtonProps) {
  return (
    <button type={type} className={cx('px-btn', `px-btn--${variant}`, `px-btn--${size}`)} disabled={disabled} onClick={onClick}>
      {children}
    </button>
  );
}
