// @vitest-environment node
// Spec §2.3, Astro rules: every component must render on the server with no browser APIs
// (no window or document during render). This file runs in plain Node, where touching either throws.
import { renderToString } from 'react-dom/server';
import { describe, expect, it } from 'vitest';
import { fixtures } from './fixtures.js';

describe('server render (no DOM)', () => {
  it('has no window or document in this environment', () => {
    expect(typeof window).toBe('undefined');
    expect(typeof document).toBe('undefined');
  });

  for (const [name, element] of Object.entries(fixtures)) {
    it(`${name} renders to HTML`, () => {
      const html = renderToString(element);
      expect(html.length).toBeGreaterThan(0);
      expect(html).not.toContain('pl-'); // old class prefix must not come back
    });
  }

  it('Tabs shows the first panel before hydration', () => {
    const html = renderToString(fixtures.Tabs!);
    expect(html).toMatch(/aria-selected="true"[^>]*>Overview/);
    expect(html).toContain('What we do');
  });
});
