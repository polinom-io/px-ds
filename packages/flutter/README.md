# px_ds

Polinom.io Design System for Flutter: the design tokens as `ThemeExtension`s, and the brand fonts.

> **Status: in build (0.x).** Tokens and fonts only; widgets come next, in the order TreatMint's screens need them.

## Install

`px_ds` is not on pub.dev. Depend on a release tag of the repository:

```yaml
dependencies:
  px_ds:
    git:
      url: https://github.com/polinom-io/px-ds.git
      path: packages/flutter
      ref: v0.1.0
```

## Use

```dart
import 'package:px_ds/px_ds.dart';

MaterialApp(
  theme: ThemeData(extensions: PxDsTheme.extensions(PxDsBrand.treatmint, Brightness.light)),
  darkTheme: ThemeData(brightness: Brightness.dark, extensions: PxDsTheme.extensions(PxDsBrand.treatmint, Brightness.dark)),
);

// In a widget:
final colors = Theme.of(context).extension<PxDsColors>()!;
final type = Theme.of(context).extension<PxDsTypography>()!;
Text('Hello', style: type.textBodyMd.copyWith(color: colors.colorTextDefault));
```

| Type | Holds |
| --- | --- |
| `PxDsColors` | Semantic colours (`colorActionPrimaryBg`, `colorTextDefault`…), one set per brand and mode |
| `PxDsElevation` | `shadow1`–`shadow4` as `List<BoxShadow>`, blur converted to render like the web |
| `PxDsTypography` | Text roles (`textHeadingLg`, `textBodyMd`…) as `TextStyle`, with the bundled fonts |
| `PxDsTokens` | Values shared by every theme: spacing, radius, sizes, opacity, breakpoints, motion durations and curves |
| `PxDsPrimitives` | The raw palette per brand. Widgets use the semantic colours, never these |
| `PxDsTheme` | `extensions(brand, brightness)` and one accessor per extension |

The extensions interpolate, so switching brightness animates like the rest of `ThemeData`. Apply `MediaQuery.textScalerOf(context)` as usual; the text roles are sized in logical pixels (1rem = 16).

## Fonts

Atkinson Hyperlegible Next (variable, 200–800, roman and italic) and Hack (regular, bold) are bundled in `assets/fonts/` and declared in `pubspec.yaml`. The text roles already point at them (`packages/px_ds/…`), so apps need no font setup. Licences are next to the files.

## Generated files

`lib/src/tokens/tokens.g.dart` and `assets/fonts/` are written by `node tools/build.mjs` at the repo root from `tokens/` and `assets/fonts/`. Never edit them here; CI fails when they don't match the sources.

## Develop

```sh
flutter pub get
flutter analyze
flutter test
```
