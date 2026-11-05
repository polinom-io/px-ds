#!/usr/bin/env node
// Independent check of the web CSS against tokens.json: simulates the cascade for every brand x mode,
// with and without data-mode, under both OS settings, and compares every colour and shadow value.
//
//   node verify-web-css.mjs tokens.json out/tokens.css
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

export function verifyWebCss(T, css) {
  const rules = []; // [inMedia, selector, decls]
  const re = /(@media \(prefers-color-scheme: dark\) \{\n)?\s*([^{}@]+?) \{\n([\s\S]*?)\n\s*\}\n/g;
  for (const m of css.matchAll(re)) {
    if (m[2].startsWith('@font-face')) continue;
    rules.push([Boolean(m[1]), m[2].trim(), Object.fromEntries([...m[3].matchAll(/--([a-z0-9-]+): ([^;]+);/g)].map((x) => [x[1], x[2]]))]);
  }
  const matches = (part, attrs) => {
    for (const c of part.matchAll(/:not\(\[([a-z-]+)\]\)|\[([a-z-]+)="([^"]+)"\]/g)) {
      if (c[1] && c[1] in attrs) return false;
      if (c[2] && attrs[c[2]] !== c[3]) return false;
    }
    return true;
  };
  const specificity = (sel, attrs) => {
    let best = -1;
    for (const part of sel.split(', ').map((p) => p.trim()))
      if (matches(part, attrs)) best = Math.max(best, (part.match(/\[[^\]]+\]/g) ?? []).length + (part.match(/:root/g) ?? []).length);
    return best;
  };
  const computed = (attrs, osDark) => {
    const val = {}, rank = {};
    rules.forEach(([media, sel, d], i) => {
      if (media && !osDark) return;
      const s = specificity(sel, attrs);
      if (s < 0) return;
      for (const [k, v] of Object.entries(d))
        if (!(k in rank) || s > rank[k][0] || (s === rank[k][0] && i >= rank[k][1])) { val[k] = v; rank[k] = [s, i]; }
    });
    return val;
  };
  const expect = (tid) => {
    const out = {};
    for (const fam of ['color', 'shadow']) for (const t of T[fam].tokens) {
      const v = typeof t.value === 'string' ? t.value : t.value[tid];
      const m = /^\{(.+)\}$/.exec(v);
      out[t.name] = m ? `var(--${m[1]})` : v;
    }
    return out;
  };
  const brands = [...new Set(T.color.themes.map((t) => t.id.slice(0, t.id.lastIndexOf('-'))))];
  const [b0, b1] = [brands[0], brands.at(-1)];
  const cases = [];
  for (const b of brands) for (const mode of ['light', 'dark']) {
    cases.push([{ 'data-theme': b, 'data-mode': mode }, mode === 'dark', `${b}-${mode}`]);
    cases.push([{ 'data-theme': b }, mode === 'dark', `${b}-${mode}`]); // no data-mode: the OS decides
  }
  cases.push([{}, false, `${b0}-light`], [{}, true, `${b0}-dark`]);
  cases.push([{ 'data-theme': b1, 'data-mode': 'light' }, true, `${b1}-light`]); // explicit light beats OS dark
  cases.push([{ 'data-theme': b1, 'data-mode': 'dark' }, false, `${b1}-dark`]); // explicit dark beats OS light
  const lines = []; let bad = 0;
  for (const [attrs, osDark, tid] of cases) {
    const c = computed(attrs, osDark), e = expect(tid);
    const miss = Object.keys(e).filter((k) => c[k] !== e[k]);
    lines.push(`${JSON.stringify(attrs).padEnd(45)} OS=${osDark ? 'dark ' : 'light'} -> ${tid.padEnd(16)} ${miss.length ? `MISMATCH ${miss.slice(0, 3)}` : 'OK'}`);
    if (miss.length) bad++;
  }
  return { ok: bad === 0, lines, summary: `${cases.length - bad}/${cases.length} cascade cases match tokens.json` };
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const [tokens, cssPath] = process.argv.slice(2);
  const r = verifyWebCss(JSON.parse(readFileSync(tokens, 'utf8')), readFileSync(cssPath, 'utf8'));
  console.log(r.lines.join('\n'));
  console.log(r.summary);
  process.exit(r.ok ? 0 : 1);
}
