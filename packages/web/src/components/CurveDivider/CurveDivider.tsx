export interface CurveDividerProps {
  /** Only when the curve means something on the page; otherwise it is hidden from assistive tech. */
  ariaLabel?: string;
}

/** CurveDivider: the Polinom.io section break. Marketing pages only, once per page, never in TreatMint. No client JavaScript needed. */
export function CurveDivider({ ariaLabel }: CurveDividerProps) {
  return (
    <div className="px-curve">
      <svg viewBox="0 0 1200 160" role={ariaLabel ? 'img' : undefined} aria-label={ariaLabel} aria-hidden={ariaLabel ? undefined : true} focusable="false">
        <line x1={0} y1={140} x2={1200} y2={140} stroke="var(--color-border-subtle)" strokeWidth={1} vectorEffect="non-scaling-stroke" />
        <path d="M0,130 C 260,132 320,60 560,78 C 780,94 820,20 1200,14" fill="none" stroke="var(--color-brand-primary)" strokeWidth={2.5} vectorEffect="non-scaling-stroke" />
        <circle cx={560} cy={78} r={4.5} fill="var(--color-brand-tertiary)" />
        <circle cx={1196} cy={14} r={4.5} fill="var(--color-brand-secondary)" />
      </svg>
    </div>
  );
}
