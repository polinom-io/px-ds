#!/usr/bin/env node
// Contrast check (spec §6, WCAG 2.2 AA). Fails the build when a pair in tokens/contrast-pairs.json
// is under its minimum in any theme. No dependencies.
//
//   node contrast-check.mjs tokens.json contrast-pairs.json
//
// Ratio: WCAG relative luminance, (L1 + 0.05) / (L2 + 0.05). A colour with alpha is composited over
// its background first. Ratios are compared unrounded (4.499 fails a 4.5 minimum).
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

function parseColor(v) {
  v = v.trim();
  let m = /^#([0-9a-f]{3,8})$/i.exec(v);
  if (m) {
    let h = m[1];
    if (h.length <= 4) h = [...h].map((c) => c + c).join('');
    if (h.length === 6) h += 'ff';
    if (h.length !== 8) throw new Error(`bad hex ${v}`);
    return [0, 2, 4, 6].map((i) => parseInt(h.slice(i, i + 2), 16) / 255);
  }
  m = /^rgba?\(\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*(?:,\s*([\d.]+)\s*)?\)$/.exec(v);
  if (m) return [+m[1] / 255, +m[2] / 255, +m[3] / 255, m[4] === undefined ? 1 : +m[4]];
  throw new Error(`unsupported colour ${v}`);
}
const over = ([r, g, b, a], [br, bg, bb]) => [r * a + br * (1 - a), g * a + bg * (1 - a), b * a + bb * (1 - a)];
const channel = (c) => (c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4);
const luminance = ([r, g, b]) => 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b);
export function ratio(fg, bg) {
  const back = parseColor(bg);
  if (back[3] < 1) throw new Error(`background ${bg} is translucent; contrast needs an opaque background`);
  const a = luminance(over(parseColor(fg), back)), b = luminance(back);
  return (Math.max(a, b) + 0.05) / (Math.min(a, b) + 0.05);
}

export function contrastCheck(T, P) {
  const toks = Object.fromEntries(T.color.tokens.map((t) => [t.name, t.value]));
  const themes = T.color.themes.map((t) => t.id);
  const resolve = (name, tid, seen = []) => {
    if (!(name in toks)) throw new Error(`contrast-pairs.json names '${name}', which is not a colour token`);
    const raw = typeof toks[name] === 'string' ? toks[name] : toks[name][tid];
    const m = /^\{(.+)\}$/.exec(raw ?? '');
    if (!m) return raw;
    if (seen.includes(m[1])) throw new Error(`alias cycle at '${name}'`);
    return resolve(m[1], tid, [...seen, name]);
  };
  const list = (x) => (x === 'surfaces' ? P.surfaces : x);
  const failures = [];
  let checked = 0, worst = null;
  for (const tid of themes) {
    for (const rule of P.rules) {
      for (const fg of rule.fg) for (const bg of list(rule.bg)) {
        if (fg === bg) continue;
        const r = ratio(resolve(fg, tid), resolve(bg, tid));
        checked++;
        const margin = r - rule.min;
        if (!worst || margin < worst.margin) worst = { margin, tid, fg, bg, r, min: rule.min };
        if (r < rule.min) failures.push({ tid, fg, bg, r, min: rule.min, why: rule.why, fgHex: resolve(fg, tid), bgHex: resolve(bg, tid) });
      }
    }
  }
  const fmt = (x) => x.toFixed(2);
  return {
    ok: failures.length === 0,
    failures,
    lines: failures.map((f) => `${f.tid.padEnd(16)} ${f.fg} ${f.fgHex} on ${f.bg} ${f.bgHex}: ${fmt(f.r)}:1, needs ${f.min}:1 (${f.why})`),
    summary: `${checked} pairs across ${themes.length} themes, ${failures.length} under the minimum` +
      (worst ? `; tightest: ${worst.tid} ${worst.fg} on ${worst.bg} ${fmt(worst.r)}:1 (needs ${worst.min}:1)` : ''),
  };
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const [tokens, pairs] = process.argv.slice(2);
  try {
    const r = contrastCheck(JSON.parse(readFileSync(tokens, 'utf8')), JSON.parse(readFileSync(pairs, 'utf8')));
    if (r.lines.length) console.log(r.lines.join('\n'));
    console.log(`${r.ok ? 'ok' : 'FAIL'}: ${r.summary}`);
    process.exit(r.ok ? 0 : 1);
  } catch (e) { console.error(`ERROR ${e.message}`); process.exit(1); }
}
