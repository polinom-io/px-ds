export interface CheckboxProps {
  label: string;
  name?: string;
  value?: string;
  defaultChecked?: boolean;
  disabled?: boolean;
  required?: boolean;
}

/** Checkbox (INP-05): the native input with its label. No client JavaScript needed. */
export function Checkbox({ label, name, value, defaultChecked, disabled, required }: CheckboxProps) {
  return (
    <label className="px-check">
      <input type="checkbox" className="px-check__input" name={name} value={value} defaultChecked={defaultChecked} disabled={disabled} required={required} />
      <span>{label}</span>
    </label>
  );
}
