// Spec §2.3: ids come from useId, so server HTML and the client's first render match.
// Each component is server-rendered, then hydrated as its own root (one Astro island each);
// React reports any mismatch through onRecoverableError or console.error.
import { act } from 'react';
import { hydrateRoot } from 'react-dom/client';
import { renderToString } from 'react-dom/server';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { fixtures } from './fixtures.js';

(globalThis as { IS_REACT_ACT_ENVIRONMENT?: boolean }).IS_REACT_ACT_ENVIRONMENT = true;

afterEach(() => { document.body.innerHTML = ''; vi.restoreAllMocks(); });

describe('hydration as separate islands', () => {
  for (const [name, element] of Object.entries(fixtures)) {
    it(`${name} hydrates without a mismatch`, async () => {
      const container = document.createElement('div');
      container.innerHTML = renderToString(element);
      document.body.appendChild(container);
      const errors: unknown[] = [];
      const consoleError = vi.spyOn(console, 'error').mockImplementation((...args) => { errors.push(args); });
      await act(async () => { hydrateRoot(container, element, { onRecoverableError: (e) => errors.push(e) }); });
      expect(errors).toEqual([]);
      consoleError.mockRestore();
    });
  }
});
