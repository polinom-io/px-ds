# Logos

Official Polinom.io logo files (delivered 2026-11-05). TreatMint logos will be added here once the brand is announced.

**Trademark:** these logos are trademarks of Polinom.io SpA. They are not covered by this repository's MIT licence and may not be used to suggest endorsement without permission.

## Which file

The `-light` suffix means **for light backgrounds**. Files without it are for dark backgrounds.

| Use | Light background | Dark background |
| --- | --- | --- |
| Horizontal lockup (default) | `polinom/polinom-logo-horizontal-light.svg` | `polinom/polinom-logo-horizontal.svg` |
| Stacked lockup | `polinom/polinom-logo-stacked-light.svg` | `polinom/polinom-logo-stacked.svg` |
| Single colour | `polinom/polinom-logo-mono.svg` (black) | `polinom/polinom-logo-mono-reversed.svg` (white) |
| Icon | `polinom/polinom-icon-light.svg` | `polinom/polinom-icon.svg` |
| Favicon | `polinom/polinom-favicon-light.svg` | `polinom/polinom-favicon.svg` |
| App icon | `polinom/polinom-app-icon-light.svg` | `polinom/polinom-app-icon.svg` |

`polinom/png/` holds square profile images (400, 512, 1024 px) for social and directory accounts.

## Rules

- Never recolour, stretch, rotate, add effects to, or redraw the logo. Keep the padding built into each file's `viewBox`.
- Each SVG embeds a C2PA content-credentials manifest in `<metadata>`. Keep it: don't run tools that strip metadata (such as `svgo` with default settings) on these files.

## Linking

Pin a release tag; never link to `main`:

```
https://cdn.jsdelivr.net/gh/polinom-io/px-ds@<tag>/assets/logos/polinom/polinom-logo-horizontal-light.svg
```

Generated documents should embed the file rather than hotlink it.
