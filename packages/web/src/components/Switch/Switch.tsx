import type { ChangeEventHandler } from 'react';

export interface SwitchProps {
  label: string;
  name?: string;
  defaultChecked?: boolean;
  disabled?: boolean;
  /** Applies the change at once (a switch has no Save button). Only inside a React island. */
  onChange?: ChangeEventHandler<HTMLInputElement>;
}

/** Switch (INP-07): a native checkbox with role="switch". */
export function Switch({ label, name, defaultChecked, disabled, onChange }: SwitchProps) {
  return (
    <label className="px-switch">
      <input type="checkbox" role="switch" className="px-switch__input" name={name} defaultChecked={defaultChecked} disabled={disabled} onChange={onChange} />
      <span className="px-switch__track" aria-hidden="true"><span className="px-switch__thumb" /></span>
      <span>{label}</span>
    </label>
  );
}
