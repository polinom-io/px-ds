// Automated accessibility check with axe-core on every component (spec §6).
// Colour contrast is not checked here: jsdom has no layout or styles. Token contrast is enforced by
// tools/contrast-check.mjs on every pull request instead.
import { render, cleanup } from '@testing-library/react';
import axe from 'axe-core';
import { afterEach, describe, expect, it } from 'vitest';
import { fixtures } from './fixtures.js';

afterEach(cleanup);

describe('axe-core', () => {
  for (const [name, element] of Object.entries(fixtures)) {
    it(`${name} has no violations`, async () => {
      const { container } = render(<main>{element}</main>);
      const result = await axe.run(container, { rules: { 'color-contrast': { enabled: false }, region: { enabled: false } } });
      expect(result.violations.map((v) => `${v.id}: ${v.help}`)).toEqual([]);
    });
  }
});
