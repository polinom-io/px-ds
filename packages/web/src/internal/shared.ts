import type { CSSProperties } from 'react';

/** Accent tone. Maps to color-accent-primary | -secondary | -tertiary | -quaternary. */
export type Tone = 'primary' | 'secondary' | 'tertiary' | 'quaternary';

const TONES: readonly Tone[] = ['primary', 'secondary', 'tertiary', 'quaternary'];

/** The CSS custom property a tone resolves to; unknown values fall back to primary. */
export function toneVar(tone: Tone | undefined): string {
  return `var(--color-accent-${tone && TONES.includes(tone) ? tone : 'primary'})`;
}

/** Inline style that hands a tone to the component's CSS through --px-tone. */
export function toneStyle(tone: Tone | undefined): CSSProperties {
  return { '--px-tone': toneVar(tone) } as CSSProperties;
}

/** Joins class names, skipping empty values. */
export function cx(...names: Array<string | false | null | undefined>): string {
  return names.filter(Boolean).join(' ');
}
