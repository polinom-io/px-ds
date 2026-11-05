import type { ReactNode } from 'react';
import { toneStyle, type Tone } from '../../internal/shared.js';

export interface CardProps {
  tone?: Tone;
  /** Small code-font chip above the title, e.g. "x³" or "// solved for". */
  exponent?: string;
  title?: string;
  /** Heading element for the title. Default "h3". */
  as?: 'h2' | 'h3' | 'h4';
  children: ReactNode;
}

/** Card (DSP-01): content on color-surface-default with a 3px accent top edge. No client JavaScript needed. */
export function Card({ tone, exponent, title, as: Heading = 'h3', children }: CardProps) {
  return (
    <div className="px-card" style={toneStyle(tone)}>
      {exponent ? <span className="px-card__exp">{exponent}</span> : null}
      {title ? <Heading className="px-card__title">{title}</Heading> : null}
      {typeof children === 'string' ? <p className="px-card__body">{children}</p> : children}
    </div>
  );
}
