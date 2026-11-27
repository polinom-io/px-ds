// Fallback font metric overrides, so `font-display: swap` doesn't shift the layout (#23).
// Node 22+, no dependencies.
//
// A fallback @font-face points at a local system font and scales it to the web font's width
// (size-adjust) and vertical metrics (ascent-, descent- and line-gap-override), so text keeps
// its size and position when the web font arrives.
//
// Width uses capsize's xWidthAvg: glyph advance widths weighted by character frequency in
// Latin text. Both values must come from the same method, so both are taken from capsize's
// metrics collection (MIT, https://github.com/seek-oss/capsize), commit
// cbfb23088c55be74ffbbe749da2c6e8d3508d2d5, packages/metrics/src/entireMetricsCollection.json.
// The build reads unitsPerEm and the hhea metrics from our own .ttf and fails if they differ
// from the recorded values, so a font update can't silently reuse stale widths.

/** capsize metrics (latin subset) for the fonts the fallbacks use. */
export const CAPSIZE_METRICS = {
	arial: {
		unitsPerEm: 2048,
		ascent: 1854,
		descent: -434,
		lineGap: 67,
		xWidthAvg: 913,
	},
	atkinsonHyperlegibleNext: {
		unitsPerEm: 1000,
		ascent: 984,
		descent: -316,
		lineGap: 0,
		xWidthAvg: 444,
	},
};

const percent = (n) => `${Number((n * 100).toFixed(2))}%`;

/**
 * Overrides for a fallback @font-face that makes `fallback` match `font`.
 * Both arguments: { unitsPerEm, ascent, descent, lineGap, xWidthAvg } in font units.
 */
export function fallbackOverrides(font, fallback) {
	const scale =
		font.xWidthAvg /
		font.unitsPerEm /
		(fallback.xWidthAvg / fallback.unitsPerEm);
	const em = font.unitsPerEm * scale;
	return {
		sizeAdjust: percent(scale),
		ascentOverride: percent(font.ascent / em),
		descentOverride: percent(Math.abs(font.descent) / em),
		lineGapOverride: percent(font.lineGap / em),
	};
}

/** unitsPerEm (head) and ascent, descent, lineGap (hhea) from a TrueType or OpenType file. */
export function readTtfMetrics(bytes) {
	const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
	const version = bytes.byteLength >= 12 ? view.getUint32(0) : 0;
	if (version !== 0x00010000 && version !== 0x4f54544f)
		throw new Error('not a TrueType or OpenType font file');
	const tables = {};
	const count = view.getUint16(4);
	for (let i = 0; i < count; i++) {
		const at = 12 + i * 16;
		const tag = String.fromCharCode(...bytes.subarray(at, at + 4));
		tables[tag] = view.getUint32(at + 8);
	}
	if (tables.head === undefined || tables.hhea === undefined)
		throw new Error('font file has no head or hhea table');
	return {
		unitsPerEm: view.getUint16(tables.head + 18),
		ascent: view.getInt16(tables.hhea + 4),
		descent: view.getInt16(tables.hhea + 6),
		lineGap: view.getInt16(tables.hhea + 8),
	};
}

/** Throws unless the font file's vertical metrics match the recorded capsize metrics. */
export function assertMatchesRecorded(fileMetrics, recorded, label) {
	for (const key of ['unitsPerEm', 'ascent', 'descent', 'lineGap']) {
		if (fileMetrics[key] !== recorded[key])
			throw new Error(
				`${label}: ${key} is ${fileMetrics[key]} in the font file but ${recorded[key]} in the recorded capsize metrics; update CAPSIZE_METRICS in tools/font-fallback.mjs from capsize`,
			);
	}
}

/** The @font-face rule for a fallback family. */
export function fallbackFace({ family, local, overrides }) {
	return `@font-face {\n  font-family: "${family}";\n  src: ${local.map((n) => `local("${n}")`).join(', ')};\n  size-adjust: ${overrides.sizeAdjust};\n  ascent-override: ${overrides.ascentOverride};\n  descent-override: ${overrides.descentOverride};\n  line-gap-override: ${overrides.lineGapOverride};\n}\n`;
}

/** Inserts the fallback family right after `family` in a CSS font stack. */
export function withFallback(stack, family, fallbackFamily) {
	const parts = stack.split(',').map((p) => p.trim());
	const at = parts.findIndex((p) => p.replace(/^"|"$/g, '') === family);
	if (at < 0) return stack;
	parts.splice(at + 1, 0, `"${fallbackFamily}"`);
	return parts.join(', ');
}
