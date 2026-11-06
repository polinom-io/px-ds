# Body outline  (`INP-19`)

> Component spec, platform-neutral. References like §2.1 point to the design system specification, which stays outside the repo until Phase 1 is `Stable`; this file is the source for this component.

**Status:** Design ☐ · Docs ☐     **Owner:** core team (spec), Flutter platform lead (build)     **Version:** 0.1.0 (draft, 6 Nov 2026)

### Platform status
| Platform | Status | Component name in code | Notes / deviations |
|---|---|---|---|
| Web (React) — Phase 1 | Won't do | — | No web consumer (spec §2.1). Revisit if a web product needs it. |
| Mobile (Flutter / Dart) — Phase 1 | In design | `PxDsBodyOutline` | TreatMint is the only consumer. |
| iOS native (SwiftUI) — Phase 2 | — | `PxDsBodyOutline` | Only if a native product needs it. |
| Android native (Compose) — Phase 2 | — | `PxDsBodyOutline` | Only if a native product needs it. |

### Purpose
A simple front and back figure of the human body, split into named regions. People tap regions to say where it hurts, and screens use the same figure to show where pain or treatment has been recorded.

### When to use / When not to use
- Use when the answer is a place on the body: logging pain, showing pain history, showing where a treatment was applied.
- Use the display-only form wherever a recorded set of regions is shown back, so people see the same figure they used when logging.
- Don't use for intensity or other values per region on its own. Values need words or numbers (region labels, below); colour shading alone is not allowed (§6.1).
- Don't use as decoration or as an illustration. For artwork, use CNT-05 Illustration.
- Don't use when only one or two fixed regions are possible. A Checkbox or Radio group is simpler.

### Used in (TreatMint)
| Screen | Form | What it shows |
|---|---|---|
| Log pain | Select, several regions | The person picks where it hurts |
| Pain history | Display-only, with labels | Regions recorded in the chosen period, with a count or the latest intensity per region |
| Treatments section | Display-only | Regions a treatment covers |

These three screens meet the inclusion rule (spec §2.3: at least 3 distinct screens).

### Anatomy
1. **Face toggle:** a two-option toggle, "Front" / "Back" (ACT-07 Toggle button, grouped). Hidden in the side-by-side layout.
2. **Figure:** the custom body form for the current face, drawn on the surface it sits on.
3. **Regions:** separate shapes inside the figure, each one target. Regions share edges; there are no gaps between them.
4. **Region label** (optional, display-only): a small badge on a region with short text, such as "3" or "7/10".
5. **Selection summary:** a line of text under the figure listing the selected regions by name ("Selected: Left knee, front; Lower back, left"), or "No areas selected".
6. **List toggle:** a text button, "Choose from a list", which swaps the figure for the same choice as a checkbox list (Accessibility, below).
7. **Helper / error text** (INP-15), under the summary.

### Artwork
- **Custom made, owned by the system.** A simple, neutral body form drawn for Polinom.io. It is not traced from a third-party illustration, so no outside licence applies. One drawing per face, front and back, with the same proportions.
- **Neutral and plain.** No face features, no musculature, no gender cues, no skin colour. Rounded joins, even outline weight. It must read as a body at 160 dp tall and stay calm at full screen.
- **Built from regions.** Each region is a closed vector shape. The outline of the whole figure is the union of the region shapes, so selections always line up with the drawing.
- **Source:** one SVG per face in `assets/body/` (`body-front.svg`, `body-back.svg`). Each region is a `<path>` whose `id` is the region id below. The token build generates the Dart paths from these files, as it does for icons (`tools/icons.mjs`), and fails if a region id is missing, duplicated or not in the region list.
- **Coordinates:** a 200 × 440 viewBox for both faces, centred on the body's midline, so the two faces can be swapped without the figure jumping.
- **Left and right are the person's own.** In the front view, the person's left side is drawn on the viewer's right; in the back view, on the viewer's left. Labels always name the person's side.

### Regions
Names follow side, area, face: "Left knee, front". A region on the midline has no side: "Neck, front". Ids are stable and never shown; labels are translated. 29 front regions and 28 back regions.

**Front (29)**

| Id | Label (English) | Id | Label (English) |
|---|---|---|---|
| `head-front` | Head, front | `neck-front` | Neck, front |
| `shoulder-right-front` | Right shoulder, front | `shoulder-left-front` | Left shoulder, front |
| `chest-right-front` | Right chest, front | `chest-left-front` | Left chest, front |
| `abdomen-upper-front` | Upper abdomen, front | `abdomen-lower-front` | Lower abdomen, front |
| `hip-right-front` | Right hip, front | `hip-left-front` | Left hip, front |
| `groin-front` | Groin, front | | |
| `upper-arm-right-front` | Right upper arm, front | `upper-arm-left-front` | Left upper arm, front |
| `elbow-right-front` | Right elbow, front | `elbow-left-front` | Left elbow, front |
| `forearm-right-front` | Right forearm, front | `forearm-left-front` | Left forearm, front |
| `hand-right-front` | Right wrist and hand, front | `hand-left-front` | Left wrist and hand, front |
| `thigh-right-front` | Right thigh, front | `thigh-left-front` | Left thigh, front |
| `knee-right-front` | Right knee, front | `knee-left-front` | Left knee, front |
| `shin-right-front` | Right shin, front | `shin-left-front` | Left shin, front |
| `ankle-right-front` | Right ankle, front | `ankle-left-front` | Left ankle, front |
| `foot-right-front` | Right foot, front | `foot-left-front` | Left foot, front |

**Back (28)**

| Id | Label (English) | Id | Label (English) |
|---|---|---|---|
| `head-back` | Head, back | `neck-back` | Neck, back |
| `shoulder-left-back` | Left shoulder, back | `shoulder-right-back` | Right shoulder, back |
| `upper-back-left-back` | Left upper back | `upper-back-right-back` | Right upper back |
| `mid-back-back` | Mid back | | |
| `lower-back-left-back` | Left lower back | `lower-back-right-back` | Right lower back |
| `tailbone-back` | Tailbone | | |
| `buttock-left-back` | Left buttock | `buttock-right-back` | Right buttock |
| `upper-arm-left-back` | Left upper arm, back | `upper-arm-right-back` | Right upper arm, back |
| `elbow-left-back` | Left elbow, back | `elbow-right-back` | Right elbow, back |
| `forearm-left-back` | Left forearm, back | `forearm-right-back` | Right forearm, back |
| `hand-left-back` | Left wrist and hand, back | `hand-right-back` | Right wrist and hand, back |
| `thigh-left-back` | Left thigh, back | `thigh-right-back` | Right thigh, back |
| `knee-left-back` | Left knee, back | `knee-right-back` | Right knee, back |
| `calf-left-back` | Left calf | `calf-right-back` | Right calf |
| `heel-left-back` | Left heel | `heel-right-back` | Right heel |

Areas that exist only on the back (upper, mid and lower back, tailbone, buttocks, calves, heels) drop the word "back" from their label, because it adds nothing. Their ids keep the face so every id has the same shape.

Each table lists the person's right first on the front and the person's left first on the back, which is the viewer's left to right in both views. Screen readers read regions in this order (Accessibility, below).

The region list is part of the API: renaming or removing a region is a breaking change (major version), because stored records reference the ids. Adding a region is a minor change.

### Variants
| Variant | Purpose | Notes |
|---|---|---|
| **Select** | Pick regions (Log pain) | `multiple: true` by default; single choice allowed for "where is it worst?" |
| **Display-only** | Show recorded regions (Pain history, Treatments) | No tap targets; regions are read as a list by screen readers |
| **Layout: switch** | One face at a time with the face toggle | Default; for phones |
| **Layout: side by side** | Front and back next to each other, no toggle | For widths ≥ 600 dp, or when both faces must be seen at once (Pain history) |

### Sizes
| Size | Figure height | Use | Notes |
|---|---|---|---|
| Small | 160 dp | Display-only in a card or list row | No region labels; selection summary required |
| Medium | 320 dp | Display-only on a detail screen | Region labels allowed |
| Large | 440 dp minimum, fills available height | Select (Log pain) | Smallest regions (wrist and hand, ankle, heel) are about 24 × 24 dp at this size; see Behavior for hit areas |

Selecting is only allowed at Large. Below 440 dp the hand and foot regions get too small to tap reliably.

### States
**Per region:** Default · Hover (pointer devices) · Focus · Pressed · Selected · Selected + Focus · Disabled (a region the screen excludes, e.g. a treatment that can't apply there).

**Whole component:** Default · Disabled · Error (e.g. "Choose at least one area" on Log pain) · Empty (display-only with nothing recorded: the figure is shown with the summary "No areas recorded").

### Behavior
- **Tapping a region** toggles it in multiple mode, or selects it and clears the rest in single mode. Selection never changes on hover, drag or long press.
- **Hit areas:** each region's tap area is its shape, plus a margin of up to 8 dp outside the figure's outline for regions on the edge (hands, feet, head, shoulders). A tap on a shared edge goes to the region whose shape contains the point; a tap in the margin goes to the nearest region within 8 dp. Taps further away do nothing.
- **Switching face** keeps the selection on both faces. The summary always lists selections from both faces, so nothing chosen on the other face is hidden.
- **Region labels** (display-only) sit at the region's label point, defined per region in the SVG (`data-label-x`, `data-label-y`). If two labels would overlap, the one on the smaller region moves outward with a leader line. Labels are at most 5 characters ("7/10", "12").
- **Animation:** a selected fill fades in over `motion-duration-fast` (120 ms) with `motion-easing-enter`; none when reduced motion is on. Switching face is an instant swap, never a flip or rotation.
- **Text scaling:** the figure does not scale with text size; the summary, labels and toggle do. At 200% text the summary wraps; it never truncates.
- **Controlled:** the component holds no selection state of its own. The screen passes the selected regions and gets changes back.

### Content guidelines
- Region labels come from the region list, translated per locale, never written per screen. The Spanish (Chile) set is part of the translations delivered with the component.
- Translations keep the side, area, face order where the language allows: "Rodilla izquierda, frente".
- The summary lists regions in the order of the region tables (head to foot), not the order they were tapped.
- With more than 4 selections, the summary shows the first 3 and "and 4 more", and the full list is available to screen readers.

### Accessibility
- **Each region is its own semantics node:** label = the region label ("Left knee, front"); in select mode, a button with a selected state (`Semantics(button: true, selected: …)`) and a tap action; in display-only mode, plain text, with the region label appended when there is one ("Left knee, front, 7 out of 10").
- **Reading order:** the face toggle, then the regions of the current face in region-table order, then the summary and the list toggle. In side-by-side layout: front regions, then back regions. Use an `OrderedTraversalPolicy` with explicit order; never the paint order.
- **Keyboard and switch access** (tablets, external keyboards, Switch Access, Full Keyboard Access): every region is focusable, in reading order; Space or Enter toggles. Focus is drawn as a ring outside the region (Tokens used), so it is visible on both selected and unselected regions.
- **Announcements:** toggling a region announces its new state ("Left knee, front, selected"). Switching face announces "Back view" or "Front view".
- **Not by colour alone:** a selected region gets a thicker outline as well as a fill, and the selection summary always names every selected region in words. Display-only values always appear as label text, never as shading alone (§6.1).
- **List alternative:** "Choose from a list" shows the same regions as checkboxes (INP-05), grouped by area (Head and neck, Arms and hands, Torso, Back, Legs and feet), bound to the same selection. This is the equivalent control that keeps small regions within WCAG 2.5.8 (target size) and serves anyone who can't use the figure. It is always available in select mode.
- **Target size:** smallest regions are about 24 × 24 dp at Large size plus the edge margin, which meets the WCAG 2.2 minimum but not the 44/48 dp touch recommendation (§6). The list alternative covers the gap.
- **The figure itself** is excluded from semantics apart from its regions; it has no image description, because the regions and summary carry its meaning.

### Tokens used
| Property | Token |
|---|---|
| Figure ground (unselected region fill) | `color-surface-sunken` |
| Region and figure outline | `color-border-control`, `border-width-hairline` |
| Selected region fill | `color-action-primary-bg` |
| Selected region outline | `color-border-strong`, `border-width-thick` |
| Hover / pressed | state layers over the region fill (FND-11: 0.08 / 0.12) |
| Disabled region | fill `color-surface-sunken`, outline `color-border-subtle`, state layer 0.38 |
| Focus ring | `color-focus-ring`, `border-width-focus`, drawn outside the region with a 2 dp gap in the surface colour |
| Region label badge | FBK-06 Badge, neutral tone, `label-sm` |
| Summary text | `body-sm`, `color-text-default`; empty state `color-text-muted` |
| Error | INP-15 Helper / error text |
| Spacing | `space-2` between figure and summary, `space-4` between toggle and figure |

**Contrast** (checked 6 Nov 2026 with `tools/contrast-check.mjs` against `tokens.json`, all four themes): outline and selected fill both pass 3:1 against `color-surface-sunken`, `-default`, `-raised` and `-page`. `color-focus-ring` fails against `color-action-primary-bg` (1.0 to 2.1:1), so the ring is never drawn on the fill; it sits outside the region on the surface, a pair that already passes. Add these pairs to `tokens/contrast-pairs.json` with the build:
- `color-border-control`, `color-border-strong`, `color-action-primary-bg` on `color-surface-sunken` and the surfaces, at 3:1 (WCAG 1.4.11).

### API (code)
| Prop | Web (React) | Flutter | SwiftUI | Compose | Default | Description |
|---|---|---|---|---|---|---|
| Selected regions | — | `selected` (`Set<PxDsBodyRegion>`) | — | — | empty | Controlled selection. |
| Change handler | — | `onChanged` (`ValueChanged<Set<PxDsBodyRegion>>?`) | — | — | `null` | `null` makes the figure display-only. |
| Multiple | — | `multiple` (`bool`) | — | — | `true` | `false` = single choice. |
| Face | — | `face` (`PxDsBodyFace.front` / `.back`) and `onFaceChanged` | — | — | `front` | Controlled, so the screen can restore it. |
| Layout | — | `layout` (`PxDsBodyLayout.switcher` / `.sideBySide`) | — | — | `switcher` | |
| Size | — | `size` (`PxDsBodySize.small` / `.medium` / `.large`) | — | — | `large` with `onChanged`, `medium` without | Asserts `large` when selecting. |
| Region labels | — | `labels` (`Map<PxDsBodyRegion, String>`) | — | — | empty | Display-only; max 5 characters each. |
| Label descriptions | — | `labelSemantics` (`Map<PxDsBodyRegion, String>`) | — | — | from `labels` | Spoken form, e.g. "7 out of 10" for "7/10". |
| Disabled regions | — | `disabledRegions` (`Set<PxDsBodyRegion>`) | — | — | empty | |
| Enabled | — | `enabled` (`bool`) | — | — | `true` | |
| Error | — | `error` (`String?`) | — | — | `null` | Non-null shows the error and marks the field invalid. |
| Helper | — | `helper` (`String?`) | — | — | `null` | |
| Semantic label | — | `label` (`String`) | — | — | required | Names the whole control, e.g. "Where does it hurt?" |

`PxDsBodyRegion` is a generated enum, one value per region id (`kneeLeftFront`), with `id` (the stored string), `face`, `side` (`left`, `right`, `none`) and `area`. Records store `id`, never the enum index.

### Related components
- INP-05 Checkbox: the list alternative.
- ACT-07 Toggle button: the face toggle.
- FBK-06 Badge: region labels.
- INP-16 Form field: label, helper and error placement match it.
- CNT-05 Illustration: for body art that isn't a control.
- INP-08 Slider: pain intensity on the Log pain screen, usually right after this component.

### Open
- Who draws the two SVGs, and the review step before they're merged: a check at 160 dp and 440 dp in all four themes, plus a test that every id in the region list exists in the artwork.
- Spanish (Chile) labels: written with the TreatMint team, then reviewed by someone clinical so the names match what patients and practitioners say.
- Whether Pain history needs intensity per region beyond a text label. If so, it needs its own legend and words; colour shading alone is not allowed.

### Changelog
| Version | Date | Change |
|---|---|---|
| 0.1.0 | 2026-11-06 | First draft: regions (29 front, 28 back), variants, behaviour, accessibility, tokens, Flutter API. |
