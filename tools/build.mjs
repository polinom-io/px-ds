#!/usr/bin/env node
// One command for the whole token build (spec §2.2, §6.1). Node 22+, no dependencies.
//
//   node tools/build.mjs            write the generated files, run every check
//   node tools/build.mjs --check    write nothing; fail if a generated file differs from what is committed
//
// Paths follow the repo layout (polinom-io/px-ds). Override any of them with --tokens, --motion,
// --pairs, --css or --dart, e.g. --tokens path/to/tokens.json.
import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'node:fs';
import { dirname } from 'node:path';
import { buildWebCss } from './build-web-css.mjs';
import { buildDart } from './build-dart.mjs';
import { verifyWebCss } from './verify-web-css.mjs';
import { verifyDart } from './verify-dart.mjs';
import { cvdCheck, band } from './cvd-check.mjs';
import { contrastCheck } from './contrast-check.mjs';

const args = process.argv.slice(2);
const opt = (name, fallback) => { const i = args.indexOf(`--${name}`); return i >= 0 ? args[i + 1] : fallback; };
const check = args.includes('--check');
const paths = {
  tokens: opt('tokens', 'tokens/tokens.json'),
  motion: opt('motion', 'tokens/motion.tokens.json'),
  pairs: opt('pairs', 'tokens/contrast-pairs.json'),
  css: opt('css', 'packages/web/src/tokens/tokens.css'),
  dart: opt('dart', 'packages/flutter/lib/src/tokens/tokens.g.dart'),
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
// Still to add (spec §12): icon generation, font copying into each package, Swift and Kotlin exports.

if (failures.length) { console.log(`\n${failures.length} step(s) failed: ${failures.join(', ')}`); process.exit(1); }
