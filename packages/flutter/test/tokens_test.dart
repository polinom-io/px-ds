import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:px_ds/px_ds.dart';

void main() {
  group('PxDsTheme.extensions', () {
    test('gives colours, elevation and typography for every brand and brightness', () {
      for (final brand in PxDsBrand.values) {
        for (final brightness in Brightness.values) {
          final types = PxDsTheme.extensions(brand, brightness).map((e) => e.runtimeType).toSet();
          expect(types, {PxDsColors, PxDsElevation, PxDsTypography}, reason: '$brand $brightness');
        }
      }
    });

    test('light and dark differ, and the two brands differ', () {
      expect(PxDsColors.pxLight.colorSurfacePage, isNot(PxDsColors.pxDark.colorSurfacePage));
      expect(PxDsColors.pxLight.colorActionPrimaryBg, isNot(PxDsColors.treatmintLight.colorActionPrimaryBg));
      expect(PxDsTheme.colors(PxDsBrand.treatmint, Brightness.dark), same(PxDsColors.treatmintDark));
    });

    test('matches the token values (spot check; tools/verify-dart.mjs checks every value)', () {
      expect(PxDsColors.pxLight.colorSurfacePage, const Color(0xFFF1F8FA));
      expect(PxDsColors.pxDark.colorSurfacePage, const Color(0xFF002B36));
      expect(PxDsTokens.space4, 16.0);
      expect(PxDsTokens.motionDurationFast, const Duration(milliseconds: 120));
    });
  });

  group('ThemeExtension contract', () {
    test('lerp returns each end at t = 0 and t = 1', () {
      final a = PxDsColors.pxLight, b = PxDsColors.pxDark;
      expect(a.lerp(b, 0).colorSurfacePage, a.colorSurfacePage);
      expect(a.lerp(b, 1).colorSurfacePage, b.colorSurfacePage);
      expect(a.lerp(null, 0.5), same(a));
      expect(PxDsElevation.pxLight.lerp(PxDsElevation.pxDark, 1).shadow4, PxDsElevation.pxDark.shadow4);
      expect(PxDsTypography.standard.lerp(PxDsTypography.standard, 0.5).textHeadingLg.fontSize, 36);
    });

    test('copyWith changes only the field given', () {
      final c = PxDsColors.pxLight.copyWith(colorSurfacePage: const Color(0xFF000000));
      expect(c.colorSurfacePage, const Color(0xFF000000));
      expect(c.colorTextDefault, PxDsColors.pxLight.colorTextDefault);
    });
  });

  group('typography', () {
    test('text roles use the fonts bundled in this package', () {
      final t = PxDsTypography.standard;
      expect(t.textBodyMd.fontFamily, 'packages/px_ds/Atkinson Hyperlegible Next');
      expect(t.textCodeMd.fontFamily, 'packages/px_ds/Hack');
      expect(t.textHeadingLg.fontWeight, FontWeight.w600);
      expect(t.textHeadingLg.fontVariations, [const FontVariation('wght', 600)]);
    });

    test('the font files are in the asset bundle', () async {
      final manifest = jsonDecode(await rootBundle.loadString('FontManifest.json')) as List<dynamic>;
      final families = manifest.map((f) => (f as Map<String, dynamic>)['family']).toSet();
      expect(families, containsAll(['packages/px_ds/Atkinson Hyperlegible Next', 'packages/px_ds/Hack']));
      for (final f in ['AtkinsonHyperlegibleNext-Var.ttf', 'AtkinsonHyperlegibleNext-VarItalic.ttf', 'hack-regular.ttf', 'hack-bold.ttf']) {
        final bytes = await rootBundle.load('packages/px_ds/assets/fonts/$f');
        expect(bytes.lengthInBytes, greaterThan(50000), reason: f);
      }
    });
  });

  testWidgets('a widget reads the extensions from its theme', (tester) async {
    late PxDsColors colors;
    late PxDsTypography type;
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: PxDsTheme.extensions(PxDsBrand.treatmint, Brightness.light)),
      home: Builder(builder: (context) {
        colors = Theme.of(context).extension<PxDsColors>()!;
        type = Theme.of(context).extension<PxDsTypography>()!;
        return Text('Hello', style: type.textBodyMd.copyWith(color: colors.colorTextDefault));
      }),
    ));
    expect(colors, same(PxDsColors.treatmintLight));
    final text = tester.widget<Text>(find.text('Hello'));
    expect(text.style!.color, PxDsColors.treatmintLight.colorTextDefault);
  });

  testWidgets('switching brightness animates between the light and dark extensions', (tester) async {
    Widget app(Brightness b) => MaterialApp(
          theme: ThemeData(brightness: b, extensions: PxDsTheme.extensions(PxDsBrand.px, b)),
          home: Builder(builder: (context) => ColoredBox(color: Theme.of(context).extension<PxDsColors>()!.colorSurfacePage)),
        );
    await tester.pumpWidget(app(Brightness.light));
    await tester.pumpWidget(app(Brightness.dark));
    await tester.pumpAndSettle();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, PxDsColors.pxDark.colorSurfacePage);
  });
}
