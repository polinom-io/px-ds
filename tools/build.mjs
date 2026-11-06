#!/usr/bin/env node
// One command for the whole token build (spec §2.2, §6.1). Node 22+, no dependencies.
//
//   node tools/build.mjs            write the generated files, run every check
//   node tools/build.mjs --check    write nothing; fail if a generated file differs from what is committed
//
// Paths follow the repo layout (polinom-io/px-ds). Override any of them with --tokens, --motion,
// --pairs, --css, --dart, --fonts, --flutter-fonts, --icons or --dart-icons, e.g. --tokens path/to/tokens.json.
import { readFileSync, writeFileSync, existsSync, mkdirSync, readdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { buildWebCss } from './build-web-css.mjs';
import { buildDart } from './build-dart.mjs';
import { verifyWebCss } from './verify-web-css.mjs';
import { verifyDart } from './verify-dart.mjs';
import { cvdCheck, band } from './cvd-check.mjs';
import { contrastCheck } from './contrast-check.mjs';
import { parseIcons, buildDartIcons } from './icons.mjs';

const args = process.argv.slice(2);
const opt = (name, fallback) => { const i = args.indexOf(`--${name}`); return i >= 0 ? args[i + 1] : fallback; };
const check = args.includes('--check');
const paths = {
  tokens: opt('tokens', 'tokens/tokens.json'),
  motion: opt('motion', 'tokens/motion.tokens.json'),
  pairs: opt('pairs', 'tokens/contrast-pairs.json'),
  css: opt('css', 'packages/web/src/tokens/tokens.css'),
  dart: opt('dart', 'packages/flutter/lib/src/tokens/tokens.g.dart'),
  fonts: opt('fonts', 'assets/fonts'),
  flutterFonts: opt('flutter-fonts', 'packages/flutter/assets/fonts'),
  icons: opt('icons', 'assets/icons'),
  dartIcons: opt('dart-icons', 'packages/flutter/lib/src/icons/icons.g.dart'),
};

const failures = [];
const step = (label, fn) => {
  try { const msg = fn(); console.log(`ok   ${label}${msg ? `: ${msg}` : ''}`); }
  catch (e) { failures.push(label); console.log(`FAIL ${label}\n${e.message}`); }
};
const emit = (path, content) => {
  if (check) {
    const current = existsSync(path) ? readFileSync(path, 'utf8') : null;
    if (current !== content) throw new Error(`${path} is out of date: run node tools/build.mjs and commit the result`);
    return 'up to date';
  }
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, content);
  return `wrote ${path}`;
};
// Same as emit, for binary files (fonts): compares bytes.
const emitCopy = (from, to) => {
  const bytes = readFileSync(from);
  if (check) {
    if (!existsSync(to) || !readFileSync(to).equals(bytes)) throw new Error(`${to} is out of date: run node tools/build.mjs and commit the result`);
    return;
  }
  mkdirSync(dirname(to), { recursive: true });
  writeFileSync(to, bytes);
};

const T = JSON.parse(readFileSync(paths.tokens, 'utf8'));
const M = JSON.parse(readFileSync(paths.motion, 'utf8'));
let css, dart;

step('web CSS export', () => { const r = buildWebCss(T, M); css = r.css; return `${r.summary}; ${emit(paths.css, css)}`; });
step('Dart export', () => { const r = buildDart(T, M); dart = r.dart; return `${r.summary}; ${emit(paths.dart, dart)}`; });
const needs = (out, what) => { if (out === undefined) throw new Error(`skipped: the ${what} export failed`); };
step('web CSS verification', () => { needs(css, 'web CSS'); const r = verifyWebCss(T, css); if (!r.ok) throw new Error(r.lines.filter((l) => l.includes('MISMATCH')).join('\n')); return r.summary; });
step('Dart verification', () => { needs(dart, 'Dart'); const r = verifyDart(T, dart); if (!r.ok) throw new Error(r.problems.slice(0, 20).join('\n')); return r.summary; });
step('contrast check (WCAG 2.2 AA, §6)', () => {
  const r = contrastCheck(T, JSON.parse(readFileSync(paths.pairs, 'utf8')));
  if (!r.ok) throw new Error(`${r.lines.join('\n')}\n${r.summary}`);
  return r.summary;
});
step('CVD report (informational, §6.1)', () => {
  const { rows } = cvdCheck(T);
  const low = rows.filter((r) => band(Math.min(r.protan, r.deutan)) === 'CONFUSABLE');
  return `${rows.length} pairs, ${low.length} under 10 (allowed: labels carry meaning)${low.length ? `\n     ${low.map((r) => `${r.brand} ${r.mode} ${r.group} ${r.pair}`).join('\n     ')}` : ''}`;
});
step('Flutter fonts (ttf + licences)', () => {
  // Flutter cannot load woff2, so packages/flutter bundles the ttf files from assets/fonts.
  const files = readdirSync(paths.fonts).filter((f) => f.endsWith('.ttf') || f.endsWith('-LICENSE.txt')).sort();
  if (!files.some((f) => f.endsWith('.ttf'))) throw new Error(`no .ttf files in ${paths.fonts}`);
  for (const f of files) emitCopy(join(paths.fonts, f), join(paths.flutterFonts, f));
  const stale = existsSync(paths.flutterFonts) ? readdirSync(paths.flutterFonts).filter((f) => !files.includes(f)) : [];
  if (stale.length) throw new Error(`${paths.flutterFonts} has files not in ${paths.fonts}: ${stale.join(', ')}`);
  return `${files.length} files ${check ? 'up to date' : `copied to ${paths.flutterFonts}`}`;
});
step('icons → Dart (Phosphor 2.1.1)', () => {
  const icons = parseIcons(paths.icons);
  return `${icons.length} icons; ${emit(paths.dartIcons, buildDartIcons(icons))}`;
});
// Still to add (spec §12): web icons from the same SVGs, Swift and Kotlin exports.

if (failures.length) { console.log(`\n${failures.length} step(s) failed: ${failures.join(', ')}`); process.exit(1); }
