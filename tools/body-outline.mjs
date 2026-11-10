#!/usr/bin/env node
// Body outline (INP-19): assets/body/{regions.json, body-front.svg, body-back.svg} -> Flutter code. No dependencies.
//
//   node body-outline.mjs assets/body out/body_regions.g.dart [docs/specs/body-outline.md]
//
// regions.json is the list of regions (stored id, face, side, area, English label, order). The two SVGs
// are the artwork: one <path id="<region id>"> per region with data-label-x/-y. The checks fail the build
// when the three disagree, so a redraw can't drop, rename or invent a region:
//   - every region in regions.json has exactly one path, on its own face, and every path is a region;
//   - viewBox is 0 0 200 440 on both faces, no transforms, path data parses;
//   - each label point lies inside its region;
//   - regions don't overlap (sampled on a grid) and leave no holes inside the figure;
//   - with the spec given, its region tables list the same ids.
import { readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parsePath } from './icons.mjs';

const camel = (n) => n.replace(/-([a-z0-9])/g, (_, c) => c.toUpperCase());
const fmt = (n) => { const s = String(Math.round(n * 1e4) / 1e4); return s.includes('.') || s.includes('e') ? s : `${s}.0`; };
const FACES = ['front', 'back'];
const VIEWBOX = '0 0 200 440';

/** Path commands -> polygon rings (curves flattened), for the geometric checks only. */
function rings(cmds) {
  const out = [];
  let ring = null, x = 0, y = 0;
  const push = (px, py) => { ring.push([px, py]); x = px; y = py; };
  for (const [c, ...a] of cmds) {
    if (c === 'M') { ring = []; out.push(ring); push(a[0], a[1]); }
    else if (c === 'L') push(a[0], a[1]);
    else if (c === 'C') { const [x0, y0] = [x, y]; for (let t = 0.125; t <= 1; t += 0.125) { const u = 1 - t; push(u * u * u * x0 + 3 * u * u * t * a[0] + 3 * u * t * t * a[2] + t * t * t * a[4], u * u * u * y0 + 3 * u * u * t * a[1] + 3 * u * t * t * a[3] + t * t * t * a[5]); } }
    else if (c === 'Q') { const [x0, y0] = [x, y]; for (let t = 0.125; t <= 1; t += 0.125) { const u = 1 - t; push(u * u * x0 + 2 * u * t * a[0] + t * t * a[2], u * u * y0 + 2 * u * t * a[1] + t * t * a[3]); } }
    else if (c === 'A') push(a[5], a[6]); // chord: good enough for the sampled checks
    else if (c === 'Z' && ring.length) { [x, y] = ring[0]; }
  }
  return out;
}

/** Non-zero winding test against the rings, matching how Flutter fills the path. */
function inside(rs, px, py) {
  let wn = 0;
  for (const r of rs) {
    for (let i = 0; i < r.length; i++) {
      const [x1, y1] = r[i], [x2, y2] = r[(i + 1) % r.length];
      const cross = (x2 - x1) * (py - y1) - (px - x1) * (y2 - y1);
      if (y1 <= py) { if (y2 > py && cross > 0) wn++; } else if (y2 <= py && cross < 0) wn--;
    }
  }
  return wn !== 0;
}

export function parseBody(dir, specPath) {
  const { regions } = JSON.parse(readFileSync(join(dir, 'regions.json'), 'utf8'));
  const problems = [];
  const ids = new Set();
  for (const r of regions) {
    if (ids.has(r.id)) problems.push(`regions.json: ${r.id} listed twice`);
    ids.add(r.id);
    if (!FACES.includes(r.face) || !r.id.endsWith(`-${r.face}`)) problems.push(`regions.json: ${r.id} has face "${r.face}"`);
    if (!['left', 'right', 'none'].includes(r.side)) problems.push(`regions.json: ${r.id} has side "${r.side}"`);
    if (!r.label) problems.push(`regions.json: ${r.id} has no label`);
    if (!r.labelEs) problems.push(`regions.json: ${r.id} has no labelEs (Spanish, Chile)`);
  }

  const paths = new Map(); // id -> { face, d, cmds, rings, label: [x, y] }
  for (const face of FACES) {
    const file = `body-${face}.svg`;
    const svg = readFileSync(join(dir, file), 'utf8');
    if (!svg.includes(`viewBox="${VIEWBOX}"`)) problems.push(`${file}: expected viewBox="${VIEWBOX}"`);
    if (/\stransform=/.test(svg)) problems.push(`${file}: has a transform; flatten it on export`);
    if (/<(circle|rect|line|polyline|polygon|ellipse)\b/.test(svg)) problems.push(`${file}: only <path> elements are read; convert other shapes to paths`);
    for (const m of svg.matchAll(/<path\b([^>]*)>/g)) {
      const attr = (n) => m[1].match(new RegExp(`\\s${n}="([^"]*)"`))?.[1];
      const id = attr('id'), d = attr('d'), lx = attr('data-label-x'), ly = attr('data-label-y');
      if (!id) { problems.push(`${file}: a <path> has no id`); continue; }
      if (paths.has(id)) { problems.push(`${file}: ${id} drawn twice`); continue; }
      if (!ids.has(id)) { problems.push(`${file}: ${id} is not in regions.json`); continue; }
      if (!id.endsWith(`-${face}`)) problems.push(`${file}: ${id} belongs on the other face`);
      if (lx === undefined || ly === undefined) problems.push(`${file}: ${id} has no data-label-x/-y`);
      let cmds;
      try { cmds = parsePath(d ?? ''); } catch (e) { problems.push(`${file}: ${id}: ${e.message}`); continue; }
      paths.set(id, { face, d, cmds, rings: rings(cmds), labelPoint: [Number(lx), Number(ly)] });
    }
  }
  for (const r of regions) if (!paths.has(r.id)) problems.push(`body-${r.face}.svg: no path for ${r.id}`);
  for (const [id, p] of paths) if (!inside(p.rings, ...p.labelPoint)) problems.push(`${id}: label point ${p.labelPoint.join(',')} is outside the region`);

  // Overlaps and holes, sampled every half unit on each face.
  for (const face of FACES) {
    const mine = [...paths].filter(([, p]) => p.face === face);
    const overlaps = new Map(), holes = [];
    for (let y = 0.25; y < 440; y += 0.5) {
      const row = [];
      for (let x = 0.25; x < 200; x += 0.5) {
        const hit = mine.filter(([, p]) => inside(p.rings, x, y)).map(([id]) => id);
        if (hit.length > 1) { const k = hit.sort().join(' / '); overlaps.set(k, (overlaps.get(k) ?? 0) + 1); }
        row.push(hit.length > 0);
      }
      // A hole is an uncovered run with covered samples on both sides that is wider than a slit (4 units).
      let i = 0;
      while (i < row.length) {
        if (row[i]) { i++; continue; }
        let j = i; while (j < row.length && !row[j]) j++;
        if (i > 0 && j < row.length && (j - i) * 0.5 < 1) holes.push(`${(i * 0.5).toFixed(1)},${y.toFixed(1)}`);
        i = j;
      }
    }
    // Shared edges sit exactly on sample lines only by accident; a handful of hits are edge noise.
    for (const [k, n] of overlaps) if (n > 6) problems.push(`body-${face}.svg: ${k} overlap (${n} samples)`);
    if (holes.length > 6) problems.push(`body-${face}.svg: ${holes.length} gaps narrower than 1 unit between regions, e.g. at ${holes.slice(0, 3).join(' ')}`);
  }

  if (specPath) {
    const spec = readFileSync(specPath, 'utf8');
    const start = spec.indexOf('### Regions'), end = spec.indexOf('### Variants');
    const listed = new Set([...spec.slice(start, end).matchAll(/\|\s*`([a-z-]+-(?:front|back))`\s*\|/g)].map((m) => m[1]));
    for (const id of ids) if (!listed.has(id)) problems.push(`${specPath}: region tables don't list ${id}`);
    for (const id of listed) if (!ids.has(id)) problems.push(`${specPath}: lists ${id}, which regions.json doesn't have`);
  }
  if (problems.length) throw new Error(problems.join('\n'));
  return regions.map((r) => ({ ...r, ...paths.get(r.id) }));
}

export function buildDartBody(regions) {
  const op = ([c, ...a]) => {
    if (c === 'M') return `..moveTo(${fmt(a[0])}, ${fmt(a[1])})`;
    if (c === 'L') return `..lineTo(${fmt(a[0])}, ${fmt(a[1])})`;
    if (c === 'C') return `..cubicTo(${a.map(fmt).join(', ')})`;
    if (c === 'Q') return `..quadraticBezierTo(${a.map(fmt).join(', ')})`;
    if (c === 'A') return `..arcToPoint(const Offset(${fmt(a[5])}, ${fmt(a[6])}), radius: const Radius.elliptical(${fmt(a[0])}, ${fmt(a[1])}), rotation: ${fmt(a[2])}, largeArc: ${a[3] === 1}, clockwise: ${a[4] === 1})`;
    return '..close()';
  };
  const L = [
    '// GENERATED by tools/body-outline.mjs from assets/body/ (regions.json, body-front.svg, body-back.svg). Do not edit.',
    '// ignore_for_file: lines_longer_than_80_chars',
    '',
    `import 'dart:ui' show Offset, Path, ${regions.some((r) => r.cmds.some(([c]) => c === 'A')) ? 'Radius, ' : ''}Rect;`,
    '',
    '/// Which side of the body a figure shows.',
    'enum PxDsBodyFace { front, back }',
    '',
    "/// The person's own side; [none] for regions on the midline.",
    'enum PxDsBodySide { left, right, none }',
    '',
    '/// One body region (INP-19). Store [id], never the index: ids are stable across versions, the order is not.',
    'enum PxDsBodyRegion {',
    ...regions.map((r, i) => `  ${camel(r.id)}(${JSON.stringify(r.id)}, PxDsBodyFace.${r.face}, PxDsBodySide.${r.side}, ${JSON.stringify(r.area)}, ${JSON.stringify(r.label)}, ${JSON.stringify(r.labelEs)}, Offset(${fmt(r.labelPoint[0])}, ${fmt(r.labelPoint[1])}))${i === regions.length - 1 ? ';' : ','}`),
    '',
    '  const PxDsBodyRegion(this.id, this.face, this.side, this.area, this.englishLabel, this.spanishLabel, this.labelPoint);',
    '',
    '  /// The stored id, e.g. `knee-left-front`.',
    '  final String id;',
    '  final PxDsBodyFace face;',
    '  final PxDsBodySide side;',
    '',
    '  /// Body area without side or face, e.g. `knee`.',
    '  final String area;',
    '',
    '  /// English label, e.g. "Left knee, front". Screens show a translated label.',
    '  final String englishLabel;',
    '',
    '  /// Spanish (Chile) label, e.g. "Rodilla izquierda, parte delantera".',
    '  final String spanishLabel;',
    '',
    '  /// Where a region label sits, in [pxDsBodyViewBox] units.',
    '  final Offset labelPoint;',
    '',
    '  /// The region outline in [pxDsBodyViewBox] units (fill, non-zero rule).',
    '  Path get path => _paths[index]();',
    '',
    '  /// The region with this stored id, or null.',
    '  static PxDsBodyRegion? fromId(String id) => _byId[id];',
    '',
    '  /// Regions on one face, in reading order (head to foot, viewer left to right).',
    '  static List<PxDsBodyRegion> onFace(PxDsBodyFace face) => [for (final r in values) if (r.face == face) r];',
    '}',
    '',
    '/// The artwork coordinate space of both faces; the midline is x = 100.',
    'const Rect pxDsBodyViewBox = Rect.fromLTWH(0, 0, 200, 440);',
    '',
    'final Map<String, PxDsBodyRegion> _byId = {for (final r in PxDsBodyRegion.values) r.id: r};',
    '',
    'final List<Path Function()> _paths = [',
    ...regions.map((r) => `  () => Path()${r.cmds.map(op).join('')},`),
    '];',
  ];
  return `${L.join('\n')}\n`;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const [dir, outPath, spec] = process.argv.slice(2);
  const regions = parseBody(dir, spec);
  writeFileSync(outPath, buildDartBody(regions));
  console.log(`ok: ${regions.length} regions -> ${outPath}`);
}
