import { useId } from 'react';
import { toneStyle, type Tone } from '../../internal/shared.js';

export interface ProgressProps {
  label: string;
  /** 0–100; values outside are clamped. */
  value: number;
  tone?: Tone;
}

/** Progress (FBK-04), determinate only. The percentage is printed, so the fill colour carries no meaning alone. */
export function Progress({ label, value, tone }: ProgressProps) {
  const id = useId();
  const v = Math.round(Math.max(0, Math.min(100, Number.isFinite(value) ? value : 0)));
  return (
    <div className="px-progress" style={toneStyle(tone)}>
      <div className="px-progress__label"><span id={id}>{label}</span><span>{v}%</span></div>
      <div className="px-progress__track" role="progressbar" aria-labelledby={id} aria-valuemin={0} aria-valuemax={100} aria-valuenow={v}>
        <div className="px-progress__fill" style={{ width: `${v}%` }} />
      </div>
    </div>
  );
}
