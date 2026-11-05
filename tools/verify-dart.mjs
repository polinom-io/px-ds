#!/usr/bin/env node
// Independent check of the Dart export against tokens.json: every semantic colour in every theme,
// every primitive per brand, shadow colours and offsets, text sizes and weights, shared values,
// plus bracket balance.
//
//   node verify-dart.mjs tokens.json out/tokens.g.dart
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const camel = (n) => { const p = n.split('-'); return p[0] + p.slice(1).map((x) => x.slice(0, 1).toUpperCase() + x.slice(1)).join(''); };
const roundHalfEven = (x) => { const f = Math.floor(x), d = x - f; return d > 0.5 ? f + 1 : d < 0.5 ? f : (f % 2 === 0 ? f : f + 1); };
const hex2 = (n) => n.toString(16).toUpperCase().padStart(2, '0');
const pyFloat = (x) => (Number.isInteger(x) ? `${x}.0` : String(x));
const escapeRe = (s) => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

function argb(v) {
  v = v.trim();
  if (v.startsWith('#')) {
    let h = v.slice(1);
    if (h.length === 3 || h.length === 4) h = [...h].map((c) => c + c).join('');
    if (h.length === 6) h += 'ff';
    return `0x${(h.slice(6, 8) + h.slice(0, 6)).toUpperCase()}`;
  }
  const [r, g, b, a] = (v.match(/[\d.]+/g) ?? []).map(Number);
  return `0x${hex2(roundHalfEven((a ?? 1) * 255))}${hex2(Math.trunc(r))}${hex2(Math.trunc(g))}${hex2(Math.trunc(b))}`;
}

export function verifyDart(T, src) {
  const vals = Object.fromEntries(T.color.tokens.map((t) => [t.name, t.value]));
  const res = (n, tid) => { const v = typeof vals[n] === 'string' ? vals[n] : vals[n][tid]; const m = /^\{(.+)\}$/.exec(v); return m ? res(m[1], tid) : v; };
  const consts = (cls) => {
    const out = {};
    for (const m of src.matchAll(new RegExp(`static const (\\w+) = ${escapeRe(cls)}\\((.*)\\);`, 'g')))
      out[m[1]] = Object.fromEntries([...`${m[2]});`.matchAll(/(\w+): (Color\(0x[0-9A-F]{8}\))(?=, \w+: |\);$)/g)].map((x) => [x[1], x[2]]));
    return out;
  };
  const bad = [];
  const themes = T.color.themes.map((t) => t.id);
  const dc = consts('PxDsColors');
  for (const tid of themes) {
    const got = dc[camel(tid)] ?? {};
    for (const n of Object.keys(vals)) {
      if (!n.startsWith('color-')) continue;
      const want = `Color(${argb(res(n, tid))})`;
      if (got[camel(n)] !== want) bad.push(`PxDsColors.${camel(tid)}.${camel(n)} = ${got[camel(n)]}, want ${want}`);
    }
  }
  const pc = consts('PxDsPrimitives._');
  for (const b of new Set(themes.map((t) => t.slice(0, t.lastIndexOf('-'))))) {
    for (const n of Object.keys(vals)) {
      if (n.startsWith('color-')) continue;
      if (pc[b]?.[camel(n)] !== `Color(${argb(res(n, `${b}-light`))})`) bad.push(`PxDsPrimitives.${b}.${camel(n)}`);
    }
  }
  const el = Object.fromEntries([...src.matchAll(/static const (\w+) = PxDsElevation\((.*)\);/g)].map((m) => [m[1], m[2]]));
  for (const tid of themes) {
    for (const t of T.shadow.tokens) {
      for (const layer of t.value[tid].split(/,(?![^(]*\))/)) {
        const nums = [...` ${layer.trim()}`.matchAll(/(?:^|\s)(-?[\d.]+)(?:px)?(?=\s)/g)].map((x) => parseFloat(x[1]));
        const col = argb(/rgba?\([^)]*\)|#\w+/.exec(layer)[0]);
        const needle = `BoxShadow(color: Color(${col}), offset: Offset(${pyFloat(nums[0] ?? 0)}, ${pyFloat(nums[1] ?? 0)})`;
        if (!(el[camel(tid)] ?? '').includes(needle)) bad.push(`PxDsElevation.${camel(tid)}.${camel(t.name)}: missing ${needle}`);
      }
    }
  }
  for (const g of T.type.groups) for (const s of g.styles) {
    const size = parseFloat(s.fontSize.replace('rem', '')) * 16;
    const re = new RegExp(`${camel(`text-${s.name}`)}: TextStyle\\([^)]*fontSize: ${escapeRe(pyFloat(size))}, [^)]*fontWeight: FontWeight\\.w${s.fontWeight}`);
    if (!re.test(src)) bad.push(`text role ${s.name}`);
  }
  for (const fam of ['spacing', 'radius', 'sizing', 'border', 'breakpoint'])
    for (const t of T[fam].tokens)
      if (!src.includes(`static const double ${camel(t.name)} = ${pyFloat(parseFloat(t.value.replace('px', '')))};`)) bad.push(`${fam} ${t.name}`);
  for (const [o, c] of [['(', ')'], ['[', ']'], ['{', '}']])
    if (src.split(o).length !== src.split(c).length) bad.push(`unbalanced ${o}${c}`);
  const first = Object.values(dc)[0] ?? {};
  return { ok: bad.length === 0, problems: bad, summary: `${Object.keys(dc).length} PxDsColors x ${Object.keys(first).length} fields, primitives, shadows, text roles and shared values match tokens.json` };
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const [tokens, dartPath] = process.argv.slice(2);
  const r = verifyDart(JSON.parse(readFileSync(tokens, 'utf8')), readFileSync(dartPath, 'utf8'));
  console.log(r.ok ? `ok: ${r.summary}` : r.problems.slice(0, 20).join('\n'));
  process.exit(r.ok ? 0 : 1);
}
