#!/usr/bin/env node
// Colour-vision (CVD) report for status and tone colours (spec §6.1). Report only: §6.1 requires an
// icon, word or label beside every status and tone, so a confusable pair does not fail the build.
//
//   node cvd-check.mjs tokens.json [results.json]
//
// Simulation: Machado, Oliveira & Fernandes 2009, severity 1.0, applied in linear sRGB.
// Distance: CIEDE2000 between the simulated colours.
// Bands (for at-a-glance scanning): >=20 distinct, 10-20 marginal, <10 confusable.
import { readFileSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const MACHADO = {
  protan: [[0.152286, 1.052583, -0.204868], [0.114503, 0.786281, 0.099216], [-0.003882, -0.048116, 1.051998]],
  deutan: [[0.367322, 0.860646, -0.227968], [0.280085, 0.672501, 0.047413], [-0.011820, 0.042940, 0.968881]],
  tritan: [[1.255528, -0.076749, -0.178779], [-0.078411, 0.930809, 0.147602], [0.004733, 0.691367, 0.303900]],
};
const hex2rgb = (h) => { h = h.replace(/^#/, ''); return [0, 2, 4].map((i) => parseInt(h.slice(i, i + 2), 16) / 255); };
const lin = (c) => (c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4);
const delin = (c) => { c = Math.min(1, Math.max(0, c)); return c <= 0.0031308 ? 12.92 * c : 1.055 * c ** (1 / 2.4) - 0.055; };
const simulate = (rgb, kind) => {
  if (kind === 'normal') return rgb;
  const L = rgb.map(lin), M = MACHADO[kind];
  return [0, 1, 2].map((i) => delin(M[i][0] * L[0] + M[i][1] * L[1] + M[i][2] * L[2]));
};
const toLab = (rgb) => {
  const [r, g, b] = rgb.map(lin);
  const X = (0.4124564 * r + 0.3575761 * g + 0.1804375 * b) / 0.95047;
  const Y = 0.2126729 * r + 0.7151522 * g + 0.0721750 * b;
  const Z = (0.0193339 * r + 0.1191920 * g + 0.9503041 * b) / 1.08883;
  const f = (t) => (t > 0.008856 ? t ** (1 / 3) : 7.787 * t + 16 / 116);
  const [fx, fy, fz] = [f(X), f(Y), f(Z)];
  return [116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz)];
};
const rad = (d) => (d * Math.PI) / 180, deg = (r) => (r * 180) / Math.PI;
const mod360 = (x) => ((x % 360) + 360) % 360;
export function de2000([L1, a1, b1], [L2, a2, b2]) {
  const C1 = Math.hypot(a1, b1), C2 = Math.hypot(a2, b2), Cb = (C1 + C2) / 2;
  const G = 0.5 * (1 - Math.sqrt(Cb ** 7 / (Cb ** 7 + 25 ** 7)));
  const a1p = (1 + G) * a1, a2p = (1 + G) * a2;
  const C1p = Math.hypot(a1p, b1), C2p = Math.hypot(a2p, b2);
  const h1p = mod360(deg(Math.atan2(b1, a1p))), h2p = mod360(deg(Math.atan2(b2, a2p)));
  const dLp = L2 - L1, dCp = C2p - C1p;
  let dh = h2p - h1p;
  if (C1p * C2p === 0) dh = 0; else if (dh > 180) dh -= 360; else if (dh < -180) dh += 360;
  const dHp = 2 * Math.sqrt(C1p * C2p) * Math.sin(rad(dh / 2));
  const Lbp = (L1 + L2) / 2, Cbp = (C1p + C2p) / 2;
  let hbp;
  if (C1p * C2p === 0) hbp = h1p + h2p;
  else if (Math.abs(h1p - h2p) <= 180) hbp = (h1p + h2p) / 2;
  else hbp = h1p + h2p < 360 ? (h1p + h2p + 360) / 2 : (h1p + h2p - 360) / 2;
  const T = 1 - 0.17 * Math.cos(rad(hbp - 30)) + 0.24 * Math.cos(rad(2 * hbp)) + 0.32 * Math.cos(rad(3 * hbp + 6)) - 0.20 * Math.cos(rad(4 * hbp - 63));
  const dth = 30 * Math.exp(-(((hbp - 275) / 25) ** 2));
  const Rc = 2 * Math.sqrt(Cbp ** 7 / (Cbp ** 7 + 25 ** 7));
  const Sl = 1 + (0.015 * (Lbp - 50) ** 2) / Math.sqrt(20 + (Lbp - 50) ** 2), Sc = 1 + 0.045 * Cbp, Sh = 1 + 0.015 * Cbp * T;
  const Rt = -Math.sin(rad(2 * dth)) * Rc;
  return Math.sqrt((dLp / Sl) ** 2 + (dCp / Sc) ** 2 + (dHp / Sh) ** 2 + Rt * (dCp / Sc) * (dHp / Sh));
}
export const band = (d) => (d >= 20 ? 'distinct' : d >= 10 ? 'marginal' : 'CONFUSABLE');

export function cvdCheck(T) {
  const toks = Object.fromEntries(T.color.tokens.map((t) => [t.name, t.value]));
  const resolve = (name, theme) => { let v = toks[name][theme]; while (v.startsWith('{')) v = toks[v.slice(1, -1)][theme]; return v; };
  // Brands and their display names come from tokens.json themes ("Polinom.io · Light" -> "Polinom.io").
  const brands = new Map();
  for (const t of T.color.themes) {
    const id = t.id.slice(0, t.id.lastIndexOf('-'));
    if (!brands.has(id)) brands.set(id, (t.name ?? id).split(' · ')[0]);
  }
  const rows = [];
  for (const [tid, label] of brands) {
    for (const mode of ['light', 'dark']) {
      const th = `${tid}-${mode}`;
      const sets = {
        status: Object.fromEntries(['success', 'warning', 'danger', 'info'].map((s) => [s, resolve(`color-feedback-${s}-fg`, th)])),
        tone: Object.fromEntries(['primary', 'secondary', 'tertiary', 'quaternary'].filter((s) => `color-accent-${s}` in toks).map((s) => [s, resolve(`color-accent-${s}`, th)])),
      };
      for (const [group, cols] of Object.entries(sets)) {
        const keys = Object.keys(cols);
        keys.forEach((a, i) => keys.slice(i + 1).forEach((b) => {
          const r = { brand: label, mode, group, pair: `${a}/${b}`, a: cols[a], b: cols[b] };
          for (const kind of ['normal', 'protan', 'deutan', 'tritan'])
            r[kind] = de2000(toLab(simulate(hex2rgb(cols[a]), kind)), toLab(simulate(hex2rgb(cols[b]), kind)));
          rows.push(r);
        }));
      }
    }
  }
  const lines = rows.map((r) => {
    const f = (x) => x.toFixed(1).padStart(5);
    return `${r.brand.padEnd(10)} ${r.mode.padEnd(5)} ${r.group.padEnd(6)} ${r.pair.padEnd(18)} ${r.a} ${r.b}  N ${f(r.normal)}  P ${f(r.protan)}  D ${f(r.deutan)}  T ${f(r.tritan)}  -> ${band(Math.min(r.protan, r.deutan))}`;
  });
  return { rows, lines };
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const [tokens, outJson] = process.argv.slice(2);
  const { rows, lines } = cvdCheck(JSON.parse(readFileSync(tokens, 'utf8')));
  if (outJson) writeFileSync(outJson, JSON.stringify(rows, null, 1));
  console.log(lines.join('\n'));
}
