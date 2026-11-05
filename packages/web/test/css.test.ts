// @vitest-environment node
// Static checks on the stylesheets, so a component cannot lose its styling silently
// (Progress once rendered an empty track because nothing read --px-tone).
import { readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import { describe, expect, it } from 'vitest';

const src = join(import.meta.dirname, '..', 'src');
const components = readdirSync(join(src, 'components'));
const read = (name: string, ext: string) => readFileSync(join(src, 'components', name, `${name}.${ext}`), 'utf8');

describe('component stylesheets', () => {
  for (const name of components) {
    const tsx = read(name, 'tsx');
    const css = read(name, 'css');

    it(`${name}: every px- class used in the markup has a rule`, () => {
      const used = new Set([...tsx.matchAll(/px-[a-z]+(?:__[a-z]+)?(?:--[a-z]+)?/g)].map((m) => m[0]).filter((c) => !c.endsWith('-')));
      const base = readFileSync(join(src, 'styles', 'base.css'), 'utf8');
      const missing = [...used].filter((c) => !c.includes('${') && !new RegExp(`\\.${c}(?![\\w-])`).test(css + base));
      expect(missing).toEqual([]);
    });

    if (tsx.includes('toneStyle(')) {
      it(`${name}: reads the tone it is given (--px-tone)`, () => {
        expect(css).toContain('var(--px-tone)');
      });
    }

    it(`${name}: uses tokens, not raw colours`, () => {
      expect(css.match(/#[0-9a-f]{3,8}\b|rgba?\(/gi) ?? []).toEqual([]);
    });
  }
});
