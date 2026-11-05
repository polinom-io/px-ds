import { useId, useRef, useState, type KeyboardEvent, type ReactNode } from 'react';

export interface TabItem {
  label: string;
  /** From an .astro page pass strings, which survive the island boundary; React elements need a React parent. */
  content: ReactNode;
}

export interface TabsProps {
  /** Accessible name of the tab list. */
  label: string;
  tabs: TabItem[];
  /** Index of the tab selected first. */
  defaultIndex?: number;
}

/**
 * Tabs (NAV-03, line variant), WAI-ARIA tabs pattern: roving tabindex, Left/Right/Home/End.
 * Interactive: hydrate with client:visible. The server render shows the first tab, so the content
 * is readable before hydration.
 */
export function Tabs({ label, tabs, defaultIndex = 0 }: TabsProps) {
  const [active, setActive] = useState(Math.min(Math.max(defaultIndex, 0), Math.max(tabs.length - 1, 0)));
  const base = useId();
  const refs = useRef<Array<HTMLButtonElement | null>>([]);
  const go = (i: number) => {
    const n = (i + tabs.length) % tabs.length;
    setActive(n);
    refs.current[n]?.focus();
  };
  const onKeyDown = (e: KeyboardEvent<HTMLDivElement>) => {
    const keys: Record<string, () => void> = {
      ArrowRight: () => go(active + 1),
      ArrowLeft: () => go(active - 1),
      Home: () => go(0),
      End: () => go(tabs.length - 1),
    };
    const run = keys[e.key];
    if (run) { e.preventDefault(); run(); }
  };
  return (
    <div className="px-tabs">
      <div className="px-tabs__list" role="tablist" aria-label={label} onKeyDown={onKeyDown}>
        {tabs.map((t, i) => (
          <button
            key={t.label}
            ref={(el) => { refs.current[i] = el; }}
            type="button"
            role="tab"
            id={`${base}-tab-${i}`}
            aria-controls={`${base}-panel-${i}`}
            aria-selected={i === active}
            tabIndex={i === active ? 0 : -1}
            className="px-tabs__tab"
            onClick={() => setActive(i)}
          >
            {t.label}
          </button>
        ))}
      </div>
      {tabs.map((t, i) => (
        <div key={t.label} role="tabpanel" id={`${base}-panel-${i}`} aria-labelledby={`${base}-tab-${i}`} hidden={i !== active} tabIndex={0} className="px-tabs__panel">
          {t.content}
        </div>
      ))}
    </div>
  );
}
