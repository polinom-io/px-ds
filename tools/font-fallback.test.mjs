// Tests for tools/font-fallback.mjs. Run with: pnpm test (node --test tools/*.test.mjs)
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { describe, it } from 'node:test';
import {
	assertMatchesRecorded,
	CAPSIZE_METRICS,
	fallbackFace,
	fallbackOverrides,
	readTtfMetrics,
	withFallback,
} from './font-fallback.mjs';

const arial = {
	unitsPerEm: 2048,
	ascent: 1854,
	descent: -434,
	lineGap: 67,
	xWidthAvg: 913,
};

describe('fallbackOverrides', () => {
	it('returns 100% and the fallback metrics when both fonts match', () => {
		const o = fallbackOverrides(arial, arial);
		assert.equal(o.sizeAdjust, '100%');
		assert.equal(o.ascentOverride, '90.53%');
		assert.equal(o.descentOverride, '21.19%');
		assert.equal(o.lineGapOverride, '3.27%');
	});

	it('scales by the width ratio and divides the vertical metrics by it', () => {
		const font = {
			unitsPerEm: 1000,
			ascent: 984,
			descent: -316,
			lineGap: 0,
			xWidthAvg: 444,
		};
		const o = fallbackOverrides(font, arial);
		// (444 / 1000) / (913 / 2048) = 0.99597
		assert.equal(o.sizeAdjust, '99.6%');
		assert.equal(o.ascentOverride, '98.8%');
		assert.equal(o.descentOverride, '31.73%');
		assert.equal(o.lineGapOverride, '0%');
	});

	it('scales Atkinson Hyperlegible Next onto Roboto (Android and Linux)', () => {
		const o = fallbackOverrides(
			CAPSIZE_METRICS.atkinsonHyperlegibleNext,
			CAPSIZE_METRICS.roboto,
		);
		// (444 / 1000) / (911 / 2048) = 0.99815
		assert.equal(o.sizeAdjust, '99.81%');
		assert.equal(o.ascentOverride, '98.58%');
		assert.equal(o.descentOverride, '31.66%');
		assert.equal(o.lineGapOverride, '0%');
	});
});

describe('readTtfMetrics', () => {
	it('reads unitsPerEm and hhea metrics from a TrueType file', () => {
		const m = readTtfMetrics(
			readFileSync('assets/fonts/AtkinsonHyperlegibleNext-Var.ttf'),
		);
		assert.equal(m.unitsPerEm, 1000);
		assert.ok(m.ascent > 0, 'ascent is positive');
		assert.ok(m.descent < 0, 'descent is negative');
		assert.ok(m.lineGap >= 0, 'lineGap is not negative');
	});

	it('rejects a file that is not TrueType or OpenType', () => {
		assert.throws(
			() => readTtfMetrics(Buffer.from('not a font at all')),
			/not a TrueType/,
		);
	});
});

describe('fallbackFace', () => {
	it('writes an @font-face that points at local fonts with the overrides', () => {
		const css = fallbackFace({
			family: 'Brand Fallback',
			local: ['Arial', 'ArialMT'],
			overrides: {
				sizeAdjust: '99.6%',
				ascentOverride: '98.8%',
				descentOverride: '31.73%',
				lineGapOverride: '0%',
			},
		});
		assert.equal(
			css,
			'@font-face {\n  font-family: "Brand Fallback";\n  src: local("Arial"), local("ArialMT");\n  size-adjust: 99.6%;\n  ascent-override: 98.8%;\n  descent-override: 31.73%;\n  line-gap-override: 0%;\n}\n',
		);
	});
});

describe('withFallback', () => {
	it('inserts the fallback family right after the web font in a stack', () => {
		assert.equal(
			withFallback('"Brand", system-ui, sans-serif', 'Brand', 'Brand Fallback'),
			'"Brand", "Brand Fallback", system-ui, sans-serif',
		);
	});

	it('chains a second fallback after the first', () => {
		const once = withFallback('"Brand", sans-serif', 'Brand', 'Brand Fallback');
		assert.equal(
			withFallback(once, 'Brand Fallback', 'Brand Fallback Roboto'),
			'"Brand", "Brand Fallback", "Brand Fallback Roboto", sans-serif',
		);
	});

	it('leaves a stack without that web font unchanged', () => {
		const stack = 'Hack, ui-monospace, monospace';
		assert.equal(withFallback(stack, 'Brand', 'Brand Fallback'), stack);
	});
});

describe('assertMatchesRecorded', () => {
	it('passes when the font file matches the recorded capsize metrics', () => {
		const file = readTtfMetrics(
			readFileSync('assets/fonts/AtkinsonHyperlegibleNext-Var.ttf'),
		);
		assert.doesNotThrow(() =>
			assertMatchesRecorded(
				file,
				CAPSIZE_METRICS.atkinsonHyperlegibleNext,
				'Atkinson',
			),
		);
	});

	it('fails with the field name when a font update changes a metric', () => {
		assert.throws(
			() =>
				assertMatchesRecorded(
					{ unitsPerEm: 1000, ascent: 990, descent: -316, lineGap: 0 },
					CAPSIZE_METRICS.atkinsonHyperlegibleNext,
					'Atkinson',
				),
			/Atkinson: ascent is 990/,
		);
	});
});
