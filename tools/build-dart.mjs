#!/usr/bin/env node
// Dart (Flutter) token export (spec §2.2). No dependencies.
//
//   node build-dart.mjs tokens.json motion.tokens.json out/tokens.g.dart
//
// Output, one file:
//   enum PxDsBrand                        px, treatmint
//   final class PxDsPrimitives            per-brand primitive palette: PxDsPrimitives.px.neutral850
//   class PxDsColors    : ThemeExtension  semantic colours, one const per brand x mode (aliases resolved)
//   class PxDsElevation : ThemeExtension  shadow1..4 as List<BoxShadow>, one const per brand x mode
//   class PxDsTypography: ThemeExtension  text roles as TextStyle (textHeadingLg), `standard` for both brands
//   abstract final class PxDsTokens       shared values: space4, radiusMd, sizeControlMd, motionDurationFast ...
//   abstract final class PxDsTheme        extensions(brand, brightness) for ThemeData(extensions: ...)
// Fails (throws) on a missing theme value, a broken or cyclic alias, a name that is not
// lowercase-hyphenated, two source names that convert to one identifier, or a Dart reserved word.
import { readFileSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const NAME = /^[a-z0-9]+(-[a-z0-9]+)*$/;
const DART_RESERVED = new Set(`abstract as assert async await base break case catch class const continue covariant default
deferred do dynamic else enum export extends extension external factory false final finally for Function get hide
if implements import in interface is late library mixin new null of on operator part required rethrow return sealed
set show static super switch sync this throw true try type typedef var void when while with yield`.split(/\s+/));
const REM = 16; // 1rem = 16 logical pixels
const GENERIC = new Set(['system-ui', 'sans-serif', 'serif', 'monospace', 'ui-monospace', 'ui-sans-serif', 'ui-serif', 'cursive']);
const isObj = (v) => v !== null && typeof v === 'object' && !Array.isArray(v);

export const camel = (name) => {
  const p = name.split('-');
  return p[0] + p.slice(1).map((x) => x.slice(0, 1).toUpperCase() + x.slice(1)).join('');
};
// Python's round(): halves go to the even neighbour (keeps output identical to the earlier Python build).
const roundHalfEven = (x) => { const f = Math.floor(x), d = x - f; return d > 0.5 ? f + 1 : d < 0.5 ? f : (f % 2 === 0 ? f : f + 1); };
const hex2 = (n) => n.toString(16).toUpperCase().padStart(2, '0');
const num = (x) => { let s = x.toFixed(4).replace(/0+$/, '').replace(/\.$/, ''); if (s === '-0') s = '0'; return s.includes('.') ? s : `${s}.0`; };

export function buildDart(T, M) {
  const errors = [];
  const color = (v, where) => {
    v = v.trim();
    let m = /^#([0-9a-fA-F]{3,8})$/.exec(v);
    if (m) {
      let h = m[1];
      if (h.length === 3 || h.length === 4) h = [...h].map((c) => c + c).join('');
      if (h.length === 6) h += 'ff';
      if (h.length !== 8) { errors.push(`${where}: bad hex ${v}`); return 'Color(0x00000000)'; }
      return `Color(0x${(h.slice(6, 8) + h.slice(0, 6)).toUpperCase()})`;
    }
    m = /^rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*([\d.]+)\s*)?\)$/.exec(v);
    if (m) {
      const a = roundHalfEven(parseFloat(m[4] ?? '1') * 255);
      return `Color(0x${hex2(a)}${hex2(+m[1])}${hex2(+m[2])}${hex2(+m[3])})`;
    }
    errors.push(`${where}: unsupported colour ${v}`); return 'Color(0x00000000)';
  };
  const px = (v, where, base) => {
    v = String(v).trim();
    const m = /^(-?[\d.]+)(px|rem|em)?$/.exec(v);
    if (!m) { errors.push(`${where}: unsupported length ${v}`); return 0; }
    let n = parseFloat(m[1]);
    if (m[2] === 'rem') n *= REM;
    if (m[2] === 'em') { if (base === undefined) { errors.push(`${where}: em needs a font size`); return 0; } n *= base; }
    return n;
  };
  // CSS box-shadow list -> Dart BoxShadow list. CSS blur b is 2*sigma; Flutter's blurRadius r maps to
  // sigma = 0.57735*r + 0.5, so r = (b/2 - 0.5) / 0.57735 to render the same blur.
  const shadows = (v, where) => {
    const out = [];
    for (const layer of v.split(/,(?![^(]*\))/)) {
      const m = /^\s*(-?[\d.]+px|0)\s+(-?[\d.]+px|0)\s+([\d.]+px|0)(?:\s+(-?[\d.]+px|0))?\s+(.+?)\s*$/.exec(layer);
      if (!m) { errors.push(`${where}: unsupported shadow layer '${layer}'`); continue; }
      const [x, y, b] = [1, 2, 3].map((i) => px(m[i], where)); const s = px(m[4] ?? '0', where);
      const r = Math.max(0, (b / 2 - 0.5) / 0.57735);
      out.push(`BoxShadow(color: ${color(m[5], where)}, offset: Offset(${num(x)}, ${num(y)}), blurRadius: ${num(r)}, spreadRadius: ${num(s)})`);
    }
    return `[${out.join(', ')}]`;
  };

  const seen = {};
  const claim = (src, where) => {
    if (!NAME.test(src)) errors.push(`${where}: '${src}' is not lowercase-hyphenated`);
    const ident = camel(src);
    if (DART_RESERVED.has(ident)) errors.push(`${where}: '${src}' becomes the Dart reserved word '${ident}'`);
    if (ident in seen) errors.push(`'${src}' (${where}) and '${seen[ident]}' both become '${ident}'`);
    seen[ident] = src;
    return ident;
  };

  const themes = T.color.themes.map((t) => t.id);
  const brands = [];
  for (const tid of themes) {
    const i = tid.lastIndexOf('-'), b = tid.slice(0, i), mode = tid.slice(i + 1);
    if (mode !== 'light' && mode !== 'dark') errors.push(`theme id '${tid}' must end in -light or -dark`);
    if (!brands.includes(b)) brands.push(b);
  }
  for (const b of brands) for (const mode of ['light', 'dark'])
    if (!themes.includes(`${b}-${mode}`)) errors.push(`brand '${b}' has no ${mode} theme`);

  const raw = {};
  for (const fam of ['color', 'shadow']) {
    for (const t of T[fam].tokens) {
      let v = t.value;
      if (typeof v === 'string') v = Object.fromEntries(themes.map((tid) => [tid, v]));
      for (const tid of themes) if (!(tid in v)) errors.push(`${fam} token '${t.name}' has no value for ${tid}`);
      raw[t.name] = [fam, v];
    }
  }
  const resolve = (name, tid, trail = []) => {
    const v = raw[name][1][tid] ?? '';
    const m = /^\{([^}]+)\}$/.exec(v);
    if (!m) return v;
    const ref = m[1];
    if (!(ref in raw) || [...trail, name].includes(ref)) { errors.push(`alias {${ref}} in '${name}' (${tid}) is missing or cyclic`); return '#000000'; }
    return resolve(ref, tid, [...trail, name]);
  };

  const colourNames = T.color.tokens.map((t) => t.name);
  const prim = colourNames.filter((n) => !n.startsWith('color-'));
  const sem = colourNames.filter((n) => n.startsWith('color-'));
  const shadowNames = T.shadow.tokens.map((t) => t.name);
  for (const n of [...colourNames, ...shadowNames]) claim(n, raw[n][0]);
  for (const b of brands) for (const n of prim)
    if (resolve(n, `${b}-light`) !== resolve(n, `${b}-dark`)) errors.push(`primitive '${n}' differs between ${b} light and dark`);

  const shared = []; // [ident, dart type, dart value]
  const kinds = { spacing: 'double', radius: 'double', sizing: 'double', border: 'double', breakpoint: 'double', opacity: 'double', zIndex: 'int' };
  for (const [fam, d] of Object.entries(T)) {
    if (['name', 'version', 'meta', 'type', 'color', 'shadow'].includes(fam) || !isObj(d) || !('tokens' in d)) continue;
    for (const t of d.tokens) {
      const ident = claim(t.name, fam), v = String(t.value);
      if (fam === 'icon') shared.push(/^[\d.]+$/.test(v) ? [ident, 'double', num(parseFloat(v))] : [ident, 'String', JSON.stringify(v)]);
      else if (kinds[fam] === 'int') shared.push([ident, 'int', String(Math.trunc(parseFloat(v)))]);
      else if (fam === 'opacity') shared.push([ident, 'double', num(parseFloat(v))]);
      else if (fam in kinds) shared.push([ident, 'double', num(px(v, t.name))]);
      else errors.push(`family '${fam}' has no Dart mapping`);
    }
  }

  const motion = [];
  const walk = (node, path, typ) => {
    for (const [k, v] of Object.entries(node)) {
      if (k.startsWith('$') || !isObj(v)) continue;
      const t = v.$type ?? typ;
      if ('$value' in v) {
        const name = ['motion', ...path, k].join('-'), ident = claim(name, 'motion.tokens.json'), val = v.$value;
        if (t === 'duration') motion.push([ident, 'Duration', `Duration(milliseconds: ${Math.trunc(val.value * (val.unit === 's' ? 1000 : 1))})`]);
        else if (t === 'cubicBezier') motion.push([ident, 'Cubic', `Cubic(${val.map(num).join(', ')})`]);
        else errors.push(`motion token ${name}: unsupported $type ${t}`);
      } else if (!('$extensions' in v) || Object.values(v).some((x) => isObj(x) && '$value' in x)) {
        walk(v, [...path, k], t);
      }
    }
  };
  walk(M.motion, [], undefined);

  const ty = T.type;
  const famFirst = Object.fromEntries(Object.entries(ty.families).map(([k, s]) => [k, s.split(/,\s*/)[0].trim().replace(/^"+|"+$/g, '')]));
  for (const k of Object.keys(ty.families)) shared.push([claim(`font-${k}`, 'type.families'), 'String', JSON.stringify(famFirst[k])]);
  const styles = [];
  for (const g of ty.groups) {
    for (const s of g.styles) {
      const ident = claim(`text-${s.name}`, 'type.styles');
      const fam = s.family || g.family;
      if (!(fam in famFirst) || GENERIC.has(famFirst[fam])) errors.push(`${ident}: family '${fam}' has no font file`);
      const size = px(s.fontSize, ident);
      const lh = /[a-z]/.test(String(s.lineHeight)) ? px(s.lineHeight, ident) : parseFloat(s.lineHeight) * size;
      const w = parseInt(String(s.fontWeight).split(/\s+/)[0], 10);
      const ls = px(s.letterSpacing || '0', ident, size);
      const parts = [`fontFamily: ${JSON.stringify(famFirst[fam])}`, `fontSize: ${num(size)}`, `height: ${num(lh / size)}`,
        `fontWeight: FontWeight.w${w}`, `fontVariations: [FontVariation('wght', ${num(w)})]`];
      if (ls) parts.push(`letterSpacing: ${num(ls)}`);
      if (s.fontStyle === 'italic') parts.push('fontStyle: FontStyle.italic');
      styles.push([ident, `TextStyle(${parts.join(', ')})`]);
    }
  }
  if (errors.length) throw new Error(errors.map((e) => `ERROR ${e}`).join('\n'));

  // ---------- emit ----------
  const L = [];
  const w = (s) => L.push(s);
  w('// GENERATED by tools/build-dart.mjs from tokens.json and motion.tokens.json. Do not edit.');
  w('// Names per spec §2.2: source `color-action-primary-bg` -> `colorActionPrimaryBg`.');
  w('// ignore_for_file: lines_longer_than_80_chars, public_member_api_docs');
  w('');
  w("import 'package:flutter/material.dart';");
  w('');
  w(`enum PxDsBrand { ${brands.join(', ')} }`);
  w('');
  w('/// Primitive palette, per brand. Themes map semantic roles onto these; components never use them.');
  w('final class PxDsPrimitives {');
  w(`  const PxDsPrimitives._({${prim.map((n) => `required this.${camel(n)}`).join(', ')}});`);
  for (const n of prim) w(`  final Color ${camel(n)};`);
  for (const b of brands) w(`  static const ${b} = PxDsPrimitives._(${prim.map((n) => `${camel(n)}: ${color(resolve(n, `${b}-light`), n)}`).join(', ')});`);
  w('}');
  w('');

  const extension = (cls, fields, typ, lerp, consts, doc) => {
    w(`/// ${doc}`);
    w('@immutable');
    w(`class ${cls} extends ThemeExtension<${cls}> {`);
    w(`  const ${cls}({${fields.map((f) => `required this.${f}`).join(', ')}});`);
    for (const f of fields) w(`  final ${typ} ${f};`);
    for (const [cname, vals] of consts) w(`  static const ${cname} = ${cls}(${fields.map((f, i) => `${f}: ${vals[i]}`).join(', ')});`);
    w('  @override');
    w(`  ${cls} copyWith({${fields.map((f) => `${typ}? ${f}`).join(', ')}}) =>`);
    w(`      ${cls}(${fields.map((f) => `${f}: ${f} ?? this.${f}`).join(', ')});`);
    w('  @override');
    w(`  ${cls} lerp(${cls}? other, double t) {`);
    w('    if (other == null) return this;');
    w(`    return ${cls}(${fields.map((f) => `${f}: ${lerp(f, `other.${f}`)}`).join(', ')});`);
    w('  }');
    w('}');
    w('');
  };
  extension('PxDsColors', sem.map(camel), 'Color', (a, b) => `Color.lerp(${a}, ${b}, t)!`,
    themes.map((tid) => [camel(tid), sem.map((n) => color(resolve(n, tid), `${n} ${tid}`))]),
    'Semantic colours. Read with `Theme.of(context).extension<PxDsColors>()!`.');
  extension('PxDsElevation', shadowNames.map(camel), 'List<BoxShadow>', (a, b) => `BoxShadow.lerpList(${a}, ${b}, t)!`,
    themes.map((tid) => [camel(tid), shadowNames.map((n) => shadows(resolve(n, tid), `${n} ${tid}`))]),
    'Elevation shadows (FND-06). In dark mode elevation is carried mainly by surface tones.');
  extension('PxDsTypography', styles.map(([i]) => i), 'TextStyle', (a, b) => `TextStyle.lerp(${a}, ${b}, t)!`,
    [['standard', styles.map(([, v]) => v)]],
    'Text roles (§5.0.1). Both brands use `standard` until TreatMint typography diverges. Apply `MediaQuery.textScalerOf`.');

  w('/// Values shared by every brand and mode (themes differ in colour only, §2.2).');
  w('abstract final class PxDsTokens {');
  for (const [ident, typ, val] of [...shared, ...motion]) w(`  static const ${typ} ${ident} = ${val};`);
  w('}');
  w('');
  w('/// Theme extensions for a brand and brightness: `ThemeData(extensions: PxDsTheme.extensions(brand, brightness))`.');
  w('abstract final class PxDsTheme {');
  for (const [cls, fn] of [['PxDsColors', 'colors'], ['PxDsElevation', 'elevation']]) {
    w(`  static ${cls} ${fn}(PxDsBrand brand, Brightness brightness) => switch ((brand, brightness)) {`);
    for (const b of brands) for (const mode of ['light', 'dark'])
      w(`        (PxDsBrand.${b}, Brightness.${mode}) => ${cls}.${camel(`${b}-${mode}`)},`);
    w('      };');
  }
  w('  static PxDsTypography typography(PxDsBrand brand) => PxDsTypography.standard;');
  w('  static PxDsPrimitives primitives(PxDsBrand brand) => switch (brand) {');
  for (const b of brands) w(`        PxDsBrand.${b} => PxDsPrimitives.${b},`);
  w('      };');
  w('  static List<ThemeExtension<dynamic>> extensions(PxDsBrand brand, Brightness brightness) =>');
  w('      [colors(brand, brightness), elevation(brand, brightness), typography(brand)];');
  w('}');
  if (errors.length) throw new Error(errors.map((e) => `ERROR ${e}`).join('\n'));
  return {
    dart: `${L.join('\n')}\n`,
    summary: `${prim.length} primitives x ${brands.length} brands, ${sem.length} semantic colours x ${themes.length} themes, ${shadowNames.length} shadows, ${styles.length} text roles, ${shared.length + motion.length} shared`,
  };
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const [tokens, motion, outPath] = process.argv.slice(2);
  try {
    const { dart, summary } = buildDart(JSON.parse(readFileSync(tokens, 'utf8')), JSON.parse(readFileSync(motion, 'utf8')));
    writeFileSync(outPath, dart);
    console.log(`ok: ${summary} -> ${outPath}`);
  } catch (e) { console.error(e.message); process.exit(1); }
}
