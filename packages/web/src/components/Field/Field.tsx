import { useId } from 'react';
import { Icon } from '../../internal/Icon.js';
import { cx } from '../../internal/shared.js';

export interface FieldProps {
  /** Always visible; never rely on the placeholder alone. */
  label: string;
  type?: 'text' | 'email' | 'tel' | 'url' | 'password' | 'textarea' | 'select';
  /** Defaults to a generated id that matches between server and client render. */
  id?: string;
  name?: string;
  placeholder?: string;
  /** Options when type="select". */
  options?: string[];
  helper?: string;
  /** Error message; sets aria-invalid and the error style. Field only displays it; validation is the consumer's. */
  error?: string;
  required?: boolean;
  disabled?: boolean;
  autoComplete?: string;
}

/** Field (INP-16, with INP-01/02/03 controls, INP-14 Label and INP-15 Helper/error text). No client JavaScript needed. */
export function Field({ label, type = 'text', id, name, placeholder, options = [], helper, error, required, disabled, autoComplete }: FieldProps) {
  const autoId = useId();
  const controlId = id ?? autoId;
  const helpId = `${controlId}-help`;
  const errorId = `${controlId}-error`;
  const describedBy = cx(helper && helpId, error && errorId) || undefined;
  const common = {
    id: controlId,
    name,
    required,
    disabled,
    autoComplete,
    'aria-invalid': error ? true : undefined,
    'aria-describedby': describedBy,
    className: 'px-field__control',
  };
  return (
    <div className={cx('px-field', error && 'px-field--error')}>
      <label className="px-field__label" htmlFor={controlId}>
        {label}
        {required ? <span className="px-field__required" aria-hidden="true"> *</span> : null}
      </label>
      {type === 'textarea' ? (
        <textarea {...common} placeholder={placeholder} />
      ) : type === 'select' ? (
        <select {...common} defaultValue="">
          <option value="" disabled>{placeholder ?? 'Select…'}</option>
          {options.map((o) => <option key={o} value={o}>{o}</option>)}
        </select>
      ) : (
        <input {...common} type={type} placeholder={placeholder} />
      )}
      {helper ? <p id={helpId} className="px-field__help">{helper}</p> : null}
      {error ? <p id={errorId} className="px-field__error"><Icon name="x-circle" size={16} />{error}</p> : null}
    </div>
  );
}
