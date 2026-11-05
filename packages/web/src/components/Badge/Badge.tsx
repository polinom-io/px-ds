import type { ReactNode } from 'react';
import { cx, toneStyle, type Tone } from '../../internal/shared.js';

export interface BadgeProps {
  tone?: Tone;
  variant?: 'soft' | 'outline' | 'solid';
  children: ReactNode;
}

/** Badge (FBK-06): a short label in an accent tone. Never for status. No client JavaScript needed. */
export function Badge({ tone, variant = 'soft', children }: BadgeProps) {
  return <span className={cx('px-badge', `px-badge--${variant}`)} style={toneStyle(tone)}>{children}</span>;
}
