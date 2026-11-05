import type { ReactNode } from 'react';
import { Icon, type IconName } from '../../internal/Icon.js';
import { cx } from '../../internal/shared.js';

export type AlertTone = 'info' | 'success' | 'warning' | 'danger';

const TONES: Record<AlertTone, { icon: IconName; title: string }> = {
  info: { icon: 'info', title: 'Info' },
  success: { icon: 'check-circle', title: 'Success' },
  warning: { icon: 'warning', title: 'Warning' },
  danger: { icon: 'x-circle', title: 'Error' },
};

export interface AlertProps {
  tone?: AlertTone;
  /** What happened. Defaults to the tone's name. */
  title?: string;
  /** What to do next. */
  children?: ReactNode;
}

/** Alert (FBK-01): icon and title always, so colour never carries the status alone. No client JavaScript needed. */
export function Alert({ tone = 'info', title, children }: AlertProps) {
  const t = TONES[tone] ?? TONES.info;
  const urgent = tone === 'danger' || tone === 'warning';
  return (
    <div className={cx('px-alert', `px-alert--${tone in TONES ? tone : 'info'}`)} role={urgent ? 'alert' : 'status'}>
      <Icon name={t.icon} size={24} className="px-alert__icon" />
      <div>
        <p className="px-alert__title">{title ?? t.title}</p>
        {children ? <div className="px-alert__body">{children}</div> : null}
      </div>
    </div>
  );
}
