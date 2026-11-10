# Body outline artwork

The figure for the Body outline component (INP-19, spec: [`docs/specs/body-outline.md`](../../docs/specs/body-outline.md)). Draft 1, for design review.

| File | Face | Regions |
|---|---|---|
| `body-front.svg` | Front | 29 |
| `body-back.svg` | Back | 28 |

## Rules for editing

These files are the source. The token build will turn them into Flutter paths and check them, so keep to these rules when you redraw in a vector tool:

- **One `<path>` per region, `id` = the region id** from the spec's region tables (`knee-left-front`). No other ids, no groups inside regions, no transforms: export with flattened coordinates.
- **Left and right are the person's own.** On the front, the person's right is on the viewer's left; on the back, the person's left is on the viewer's left.
- **Regions tile the figure.** Neighbours share their edge exactly, with no gaps and no overlaps; the outline of the figure is the outer edge of the regions.
- **`viewBox="0 0 200 440"`** for both faces, with the body's midline at x = 100, so swapping faces doesn't move the figure.
- **`data-label-x` / `data-label-y`** on each path: where a region label (badge) sits, inside the region.
- **Plain and neutral:** no face, muscles, gender cues or skin tone.
- **Colours in the file are for previewing only.** The widget paints every region from semantic tokens (`color-surface-sunken`, `color-border-control`, `color-action-primary-bg`, …), so any fill and stroke here are ignored.

## Draft 1 notes

- Drawn from simple geometry (ellipse head, tapered limbs) and cut into regions along straight lines, so shared edges are exact.
- Smallest regions at the 440 dp selecting size: front ankles 16 × 18 dp and feet 19 × 22 dp, under the 24 × 24 minimum; back elbows, hands and heels are larger (about 19–21 wide, 28–34 tall). The spec relies on the checkbox list for the ankles and feet (WCAG 2.5.8 equivalent-control exception). The review should decide whether that's acceptable or the ankle merges into the foot.
- Not yet checked by the build: that comes with the region build step.
