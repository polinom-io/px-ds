#!/usr/bin/env node
// Web CSS export (spec §2.2, v0.35). No dependencies.
//
//   node build-web-css.mjs tokens.json motion.tokens.json out/tokens.css [font-url-base]
//
// Theme ids in tokens.json are "<brand>-<mode>" (px-light). They become two attributes:
//   [data-theme="px"]                       light values (first brand also on :root)
//   [data-theme="px"][data-mode="dark"]     dark values that differ from light
//   @media (prefers-color-scheme: dark) { [data-theme="px"]:not([data-mode]) { same dark values } }
// Fails (throws) on: a colour/shadow token missing a theme value, an alias to a missing token or a
// cycle, a name that is not lowercase-hyphenated, or two tokens with one name.
import { readFileSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const NAME = /^[a-z0-9]+(-[a-z0-9]+)*$/;
const THEMED = ['color', 'shadow'];
const SKIP = new Set(['name', 'version', 'meta', 'type', 'color', 'shadow']);
const isObj = (v) => v !== null && typeof v === 'object' && !Array.isArray(v);

export function flattenMotion(node, path = []) {
  const out = {};
  const inherited = node.$type;
  for (const [k, v] of Object.entries(node)) {
    if (k.startsWith('$') || !isObj(v)) continue;
    if ('$value' in v) {
      const val = v.$value, t = v.$type ?? inherited;
      let css;
      if (t === 'duration') css = `${val.value}${val.unit}`;
      else if (t === 'cubicBezier') css = `cubic-bezier(${val.map(String).join(',')})`;
      else throw new Error(`motion token ${[...path, k].join('-')}: unsupported $type ${t}`);
      out[['motion', ...path, k].join('-')] = css;
    } else if ('$extensions' in v && !Object.values(v).some((x) => isObj(x) && '$value' in x)) {
      continue; // behaviour rule, not a value token (e.g. motion.reduced)
    } else {
      Object.assign(out, flattenMotion({ ...v, $type: v.$type ?? inherited }, [...path, k]));
    }
  }
  return out;
}

export function buildWebCss(T, M, fontBase = 'fonts/') {
  const errors = [], seen = {};
  const claim = (name, where) => {
    if (!NAME.test(name)) errors.push(`${where}: '${name}' is not lowercase-hyphenated`);
    if (name in seen) errors.push(`duplicate name '${name}' (${seen[name]} and ${where})`);
    seen[name] = where;
  };
  const themes = T.color.themes.map((t) => t.id);
  const brands = [], modes = {};
  for (const tid of themes) {
    const i = tid.lastIndexOf('-'), brand = tid.slice(0, i), mode = tid.slice(i + 1);
    if (mode !== 'light' && mode !== 'dark') errors.push(`theme id '${tid}' must end in -light or -dark`);
    if (!brands.includes(brand)) brands.push(brand);
    modes[`${brand}|${mode}`] = tid;
  }
  for (const b of brands) for (const m of ['light', 'dark'])
    if (!(`${b}|${m}` in modes)) errors.push(`brand '${b}' has no ${m} theme`);

  const themed = {};
  for (const fam of THEMED) {
    for (const t of T[fam]?.tokens ?? []) {
      claim(t.name, fam);
      let v = t.value;
      if (typeof v === 'string') v = Object.fromEntries(themes.map((tid) => [tid, v]));
      for (const tid of themes) if (!(tid in v)) errors.push(`${fam} token '${t.name}' has no value for ${tid}`);
      themed[t.name] = v;
    }
  }
  const cssValue = (name, tid) => {
    const v = themed[name][tid];
    const m = /^\{([^}]+)\}$/.exec(v);
    if (!m) return v;
    const ref = m[1];
    const chain = [name];
    for (let r = ref; ; ) { // follow the alias chain: every link must exist and none may repeat
      if (!(r in themed) || chain.includes(r)) { errors.push(`alias {${ref}} in '${name}' (${tid}) is missing or cyclic`); return v; }
      chain.push(r);
      const next = /^\{([^}]+)\}$/.exec(themed[r][tid] ?? '');
      if (!next) break;
      r = next[1];
    }
    return `var(--${ref})`;
  };
  for (const n of Object.keys(themed)) for (const tid of themes) if (tid in themed[n]) cssValue(n, tid); // reject broken aliases now
  const plain = [];
  for (const [fam, d] of Object.entries(T)) {
    if (SKIP.has(fam) || !isObj(d) || !('tokens' in d)) continue;
    for (const t of d.tokens) { claim(t.name, fam); plain.push([t.name, String(t.value)]); }
  }
  for (const [k, v] of Object.entries(flattenMotion(M.motion))) { claim(k, 'motion.tokens.json'); plain.push([k, v]); }
  const ty = T.type;
  for (const [k, v] of Object.entries(ty.families)) { claim(`font-${k}`, 'type.families'); plain.push([`font-${k}`, v]); }
  for (const g of ty.groups) {
    for (const s of g.styles) {
      const name = `text-${s.name}`; claim(name, 'type.styles');
      const fam = s.family || g.family;
      const style = s.fontStyle === 'italic' ? 'italic ' : '';
      plain.push([name, `${style}${s.fontWeight} ${s.fontSize}/${s.lineHeight} var(--font-${fam})`]);
      const ls = s.letterSpacing;
      if (ls && !['0', '0em', 'normal'].includes(ls)) plain.push([`${name}-tracking`, ls]);
    }
  }
  if (errors.length) throw new Error(errors.map((e) => `ERROR ${e}`).join('\n'));

  const block = (sel, decls, scheme, indent = '') => {
    const body = [...(scheme ? [`color-scheme: ${scheme};`] : []), ...decls.map(([n, v]) => `--${n}: ${v};`)];
    return `${indent}${sel} {\n${body.map((l) => `${indent}  ${l}`).join('\n')}\n${indent}}\n`;
  };
  const out = [
    '/* Polinom.io Design System tokens. Generated by tools/build-web-css.mjs from tokens.json and',
    '   motion.tokens.json; do not edit. Attributes (spec §2.2): data-theme = brand, data-mode = light|dark;',
    '   no data-mode follows prefers-color-scheme. */\n',
  ];
  out.push(block(':root', plain));
  const names = Object.keys(themed);
  brands.forEach((b, i) => {
    const light = names.map((n) => [n, cssValue(n, modes[`${b}|light`])]);
    const dark = names.map((n) => [n, cssValue(n, modes[`${b}|dark`])]);
    const diff = dark.filter((d, j) => d[1] !== light[j][1]);
    const first = i === 0;
    out.push(block(first ? `:root, [data-theme="${b}"]` : `[data-theme="${b}"]`, light, 'light'));
    let selDark = `[data-theme="${b}"][data-mode="dark"]`, selAuto = `[data-theme="${b}"]:not([data-mode])`;
    if (first) {
      selDark = `:root:not([data-theme])[data-mode="dark"], ${selDark}`;
      selAuto = `:root:not([data-theme]):not([data-mode]), ${selAuto}`;
    }
    out.push(block(selDark, diff, 'dark'));
    out.push(`@media (prefers-color-scheme: dark) {\n${block(selAuto, diff, 'dark', '  ')}}\n`);
  });
  for (const f of ty.fonts) {
    const file = f.file.includes('/') ? f.file.slice(f.file.indexOf('/') + 1) : f.file;
    out.push(`@font-face {\n  font-family: "${f.family}";\n  src: url("${fontBase}${file}") format("${file.slice(file.lastIndexOf('.') + 1)}");\n  font-weight: ${f.weight};\n  font-style: ${f.style ?? 'normal'};\n  font-display: swap;\n}\n`);
  }
  return { css: out.join('\n'), summary: `${names.length} themed + ${plain.length} shared tokens, brands ${brands.join(', ')}` };
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const [tokens, motion, outPath, fontBase = 'fonts/'] = process.argv.slice(2);
  try {
    const { css, summary } = buildWebCss(JSON.parse(readFileSync(tokens, 'utf8')), JSON.parse(readFileSync(motion, 'utf8')), fontBase);
    writeFileSync(outPath, css);
    console.log(`ok: ${summary}, wrote ${outPath}`);
  } catch (e) { console.error(e.message); process.exit(1); }
}
