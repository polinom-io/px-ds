export interface StatProps {
  /** A real, structural figure ("4", "1"), never an invented track record. */
  value: string;
  /** Reads as a sentence with the value. */
  label: string;
}

/** Stat (DSP-09). No client JavaScript needed. */
export function Stat({ value, label }: StatProps) {
  return (
    <div className="px-stat">
      <div className="px-stat__figure">{value}</div>
      <div className="px-stat__label">{label}</div>
    </div>
  );
}
