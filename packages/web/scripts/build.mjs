#!/usr/bin/env node
// Builds dist/ for @polinom-io/px-ds-react:
//   dist/index.js + .d.ts, dist/components/<Name>/index.js + .d.ts   compiled by tsc (ESM, one entry per component)
//   dist/components/<Name>/<Name>.css                                 one stylesheet per component
//   dist/styles.css                                                   base + every component, in a fixed order
//   dist/tokens.css, dist/fonts/*.woff2                               generated tokens and the web fonts they reference
// No CSS is imported from JavaScript, so server rendering in Astro never has to resolve a stylesheet.
import { execFileSync } from 'node:child_process';
import { cpSync, mkdirSync, readFileSync, readdirSync, rmSync, writeFileSync, existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const dist = join(root, 'dist');
const fonts = join(root, '..', '..', 'assets', 'fonts');
// Order matters only where rules share specificity; base first, then components alphabetically.
const components = readdirSync(join(root, 'src', 'components')).sort();

rmSync(dist, { recursive: true, force: true });
execFileSync(process.execPath, [join(root, 'node_modules', 'typescript', 'bin', 'tsc'), '-p', join(root, 'tsconfig.json')], { stdio: 'inherit' });

const parts = [readFileSync(join(root, 'src', 'styles', 'base.css'), 'utf8')];
for (const name of components) {
  const css = join(root, 'src', 'components', name, `${name}.css`);
  if (!existsSync(css)) throw new Error(`missing stylesheet for ${name}`);
  const text = readFileSync(css, 'utf8');
  mkdirSync(join(dist, 'components', name), { recursive: true });
  writeFileSync(join(dist, 'components', name, `${name}.css`), text);
  parts.push(text);
}
writeFileSync(join(dist, 'styles.css'), `/* @polinom-io/px-ds-react: base and component styles. Load after tokens.css. */\n${parts.join('\n')}`);

cpSync(join(root, 'src', 'tokens', 'tokens.css'), join(dist, 'tokens.css'));
mkdirSync(join(dist, 'fonts'), { recursive: true });
for (const f of readdirSync(fonts)) if (f.endsWith('.woff2') || f.endsWith('-LICENSE.txt')) cpSync(join(fonts, f), join(dist, 'fonts', f));

console.log(`built dist/: ${components.length} components, styles.css, tokens.css, fonts`);
