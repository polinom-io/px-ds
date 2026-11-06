#!/usr/bin/env node
// Icons: assets/icons/*.svg (Phosphor 2.1.1, single-path, 256-unit grid) -> Flutter code. No dependencies.
//
//   node icons.mjs assets/icons out/icons.g.dart
//
// Each SVG path is parsed into absolute commands (M L H V C S Q Z and elliptical arcs A) and written as
// a Path builder, so Flutter draws the exact Phosphor outline with no SVG package. parseIcons() and
// toSvgPath() are exported so a test can redraw every icon from the parsed commands and compare.
import { readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';

const camel = (n) => n.replace(/-([a-z0-9])/g, (_, c) => c.toUpperCase());
const fmt = (n) => { const s = String(Math.round(n * 1e4) / 1e4); return s.includes('.') || s.includes('e') ? s : `${s}.0`; };

/** SVG path data -> absolute commands: [['M',x,y], ['L',x,y], ['C',x1,y1,x2,y2,x,y], ['Q',x1,y1,x,y], ['A',rx,ry,rot,large,sweep,x,y], ['Z']]. */
export function parsePath(d) {
  const tokens = d.match(/[a-zA-Z]|[-+]?(?:\d*\.\d+|\d+\.?)(?:[eE][-+]?\d+)?/g) ?? [];
  const out = [];
  let i = 0, cmd = '', x = 0, y = 0, sx = 0, sy = 0, lastC = null, lastQ = null;
  const num = () => { const t = tokens[i++]; if (t === undefined || /[a-zA-Z]/.test(t)) throw new Error(`bad path near token ${i}: ${d.slice(0, 60)}`); return parseFloat(t); };
  // Arc flags are single digits and may be written without separators ("011").
  const flag = () => {
    const t = tokens[i];
    if (t === '0' || t === '1') { i++; return +t; }
    if (/^[01]/.test(t ?? '')) { tokens[i] = t.slice(1); return +t[0]; }
    throw new Error(`bad arc flag near token ${i}`);
  };
  while (i < tokens.length) {
    if (/[a-zA-Z]/.test(tokens[i])) cmd = tokens[i++];
    const rel = cmd === cmd.toLowerCase(), C = cmd.toUpperCase();
    const ox = rel ? x : 0, oy = rel ? y : 0;
    if (C === 'M') {
      x = ox + num(); y = oy + num(); sx = x; sy = y; out.push(['M', x, y]);
      cmd = rel ? 'l' : 'L'; lastC = lastQ = null; continue; // further pairs are implicit lines
    }
    if (C === 'Z') { out.push(['Z']); x = sx; y = sy; lastC = lastQ = null; continue; }
    if (C === 'L') { x = ox + num(); y = oy + num(); out.push(['L', x, y]); lastC = lastQ = null; }
    else if (C === 'H') { x = ox + num(); out.push(['L', x, y]); lastC = lastQ = null; }
    else if (C === 'V') { y = oy + num(); out.push(['L', x, y]); lastC = lastQ = null; }
    else if (C === 'C') {
      const x1 = ox + num(), y1 = oy + num(), x2 = ox + num(), y2 = oy + num(); x = ox + num(); y = oy + num();
      out.push(['C', x1, y1, x2, y2, x, y]); lastC = [x2, y2]; lastQ = null;
    } else if (C === 'S') {
      const [rx1, ry1] = lastC ? [2 * x - lastC[0], 2 * y - lastC[1]] : [x, y];
      const x2 = ox + num(), y2 = oy + num(); x = ox + num(); y = oy + num();
      out.push(['C', rx1, ry1, x2, y2, x, y]); lastC = [x2, y2]; lastQ = null;
    } else if (C === 'Q') {
      const x1 = ox + num(), y1 = oy + num(); x = ox + num(); y = oy + num();
      out.push(['Q', x1, y1, x, y]); lastQ = [x1, y1]; lastC = null;
    } else if (C === 'T') {
      const [x1, y1] = lastQ ? [2 * x - lastQ[0], 2 * y - lastQ[1]] : [x, y];
      x = ox + num(); y = oy + num(); out.push(['Q', x1, y1, x, y]); lastQ = [x1, y1]; lastC = null;
    } else if (C === 'A') {
      const rx = num(), ry = num(), rot = num(), large = flag(), sweep = flag(); x = ox + num(); y = oy + num();
      out.push(['A', rx, ry, rot, large, sweep, x, y]); lastC = lastQ = null;
    } else throw new Error(`unsupported path command ${cmd}`);
  }
  return out;
}

/** Absolute commands back to SVG path data (used to check the parser by redrawing). */
export const toSvgPath = (cmds) => cmds.map(([c, ...a]) => (c === 'A' ? `A${a[0]},${a[1]},${a[2]},${a[3]},${a[4]},${a[5]},${a[6]}` : `${c}${a.join(',')}`)).join('');

export function parseIcons(dir) {
  return readdirSync(dir).filter((f) => f.endsWith('.svg')).sort().map((f) => {
    const svg = readFileSync(join(dir, f), 'utf8');
    if (!/viewBox="0 0 256 256"/.test(svg)) throw new Error(`${f}: expected viewBox 0 0 256 256`);
    const paths = [...svg.matchAll(/<path[^>]*\sd="([^"]+)"/g)].map((m) => m[1]);
    if (paths.length !== 1 || /<(circle|rect|line|polyline|polygon|ellipse)\b/.test(svg)) throw new Error(`${f}: expected exactly one <path> and no other shapes`);
    return { name: f.replace(/\.svg$/, ''), d: paths[0], cmds: parsePath(paths[0]) };
  });
}

export function buildDartIcons(icons) {
  const dartOp = ([c, ...a]) => {
    if (c === 'M') return `..moveTo(${fmt(a[0])}, ${fmt(a[1])})`;
    if (c === 'L') return `..lineTo(${fmt(a[0])}, ${fmt(a[1])})`;
    if (c === 'C') return `..cubicTo(${a.map(fmt).join(', ')})`;
    if (c === 'Q') return `..quadraticBezierTo(${a.map(fmt).join(', ')})`;
    if (c === 'A') return `..arcToPoint(const Offset(${fmt(a[5])}, ${fmt(a[6])}), radius: const Radius.elliptical(${fmt(a[0])}, ${fmt(a[1])}), rotation: ${fmt(a[2])}, largeArc: ${a[3] === 1}, clockwise: ${a[4] === 1})`;
    return '..close()';
  };
  const L = [
    '// GENERATED by tools/icons.mjs from assets/icons/*.svg (Phosphor 2.1.1, MIT). Do not edit.',
    '// ignore_for_file: lines_longer_than_80_chars, public_member_api_docs',
    '',
    "import 'dart:ui' show Offset, Path, Radius;",
    '',
    '/// One Phosphor icon on its 256-unit grid. Draw it with `PxDsIcon`.',
    'final class PxDsIconData {',
    '  const PxDsIconData._(this.name, this._build);',
    '  final String name;',
    '  final Path Function() _build;',
    '',
    '  /// The outline on the 256 x 256 grid (fill, non-zero rule).',
    '  Path get path => _build();',
    '',
    '  @override',
    "  String toString() => 'PxDsIconData($name)';",
    '}',
    '',
    '/// Phosphor icons used by the design system. `regular` at rest; `*Fill` only for a selected state.',
    'abstract final class PxDsIcons {',
    ...icons.map(({ name }) => `  static const ${camel(name)} = PxDsIconData._(${JSON.stringify(name)}, _${camel(name)});`),
    '',
    `  static const List<PxDsIconData> all = [${icons.map(({ name }) => camel(name)).join(', ')}];`,
    '}',
    '',
    ...icons.map(({ name, cmds }) => `Path _${camel(name)}() => Path()${cmds.map(dartOp).join('')};`),
  ];
  return `${L.join('\n')}\n`;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const [dir, outPath] = process.argv.slice(2);
  const icons = parseIcons(dir);
  writeFileSync(outPath, buildDartIcons(icons));
  console.log(`ok: ${icons.length} icons -> ${outPath}`);
}
