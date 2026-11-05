import { cx, toneStyle, type Tone } from '../../internal/shared.js';

export interface AvatarProps {
  /** 1–2 letters. */
  initials: string;
  /** Accessible name when no visible name sits beside the avatar. */
  name?: string;
  tone?: Tone;
  size?: 'sm' | 'md' | 'lg';
}

/** Avatar (DSP-04), initials only. No client JavaScript needed. */
export function Avatar({ initials, name, tone, size = 'md' }: AvatarProps) {
  return (
    <span
      className={cx('px-avatar', `px-avatar--${size}`)}
      style={toneStyle(tone)}
      role={name ? 'img' : undefined}
      aria-label={name}
      aria-hidden={name ? undefined : true}
    >
      {initials}
    </span>
  );
}
