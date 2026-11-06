import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:px_ds/px_ds.dart';

import 'support.dart';

void main() {
  group('PxDsButton', () {
    testWidgets('calls onPressed and exposes a button with its label', (tester) async {
      var taps = 0;
      await tester.pumpWidget(themed(PxDsButton(label: 'Save changes', onPressed: () => taps++)));
      await tester.tap(find.text('Save changes'));
      expect(taps, 1);
      expect(tester.getSemantics(find.byType(TextButton)), containsSemantics(label: 'Save changes', isButton: true, isEnabled: true, hasTapAction: true));
    });

    testWidgets('null onPressed is disabled and faded', (tester) async {
      await tester.pumpWidget(themed(const PxDsButton(label: 'Save', onPressed: null)));
      expect(tester.getSemantics(find.byType(TextButton)), containsSemantics(isButton: true, isEnabled: false));
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, PxDsTokens.opacityDisabled);
    });

    testWidgets('every size keeps a 48 x 48 touch target', (tester) async {
      for (final size in PxDsButtonSize.values) {
        await tester.pumpWidget(themed(Center(child: PxDsButton(label: 'Go', size: size, onPressed: () {}))));
        final box = tester.getSize(find.byType(TextButton));
        expect(box.height, greaterThanOrEqualTo(48), reason: '$size');
        expect(box.width, greaterThanOrEqualTo(48), reason: '$size');
      }
    });

    testWidgets('uses the action colours for each variant', (tester) async {
      Color fill(PxDsButtonVariant v) {
        final style = tester.widget<TextButton>(find.byType(TextButton)).style!;
        return style.backgroundColor!.resolve({})!;
      }
      for (final v in PxDsButtonVariant.values) {
        await tester.pumpWidget(themed(PxDsButton(label: 'Go', variant: v, onPressed: () {})));
        final c = PxDsColors.pxLight;
        final expected = switch (v) {
          PxDsButtonVariant.primary => c.colorActionPrimaryBg,
          PxDsButtonVariant.secondary => c.colorActionSecondaryBg,
          PxDsButtonVariant.ghost => const Color(0x00000000),
          PxDsButtonVariant.danger => c.colorActionDestructiveBg,
        };
        expect(fill(v), expected, reason: '$v');
      }
    });
  });

  group('PxDsTextField', () {
    testWidgets('one semantics node with label, required and the error', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(themed(const PxDsTextField(label: 'Email', required: true, error: 'Enter a valid email address.')));
      final node = tester.getSemantics(find.byType(TextField));
      expect(node.getSemanticsData().label, contains('Email, required'));
      expect(node, containsSemantics(isTextField: true));
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(find.byType(PxDsIcon), findsOneWidget); // the error has an icon, not colour alone
      handle.dispose();
    });

    testWidgets('shows the helper only when there is no error', (tester) async {
      await tester.pumpWidget(themed(const PxDsTextField(label: 'Name', helper: 'As on your ID')));
      expect(find.text('As on your ID'), findsOneWidget);
      await tester.pumpWidget(themed(const PxDsTextField(label: 'Name', helper: 'As on your ID', error: 'Required')));
      expect(find.text('As on your ID'), findsNothing);
    });

    testWidgets('reports typing', (tester) async {
      String? value;
      await tester.pumpWidget(themed(PxDsTextField(label: 'Name', onChanged: (v) => value = v)));
      await tester.enterText(find.byType(TextField), 'Mario');
      expect(value, 'Mario');
    });
  });

  testWidgets('PxDsCard marks its title as a heading', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(themed(const PxDsCard(tone: PxDsTone.secondary, exponent: 'x³', title: 'Strategy', body: 'The highest-degree term.')));
    expect(tester.getSemantics(find.text('Strategy')), containsSemantics(isHeader: true));
    handle.dispose();
  });

  group('PxDsAlert', () {
    testWidgets('warning and danger are live regions; info and success are not', (tester) async {
      final handle = tester.ensureSemantics();
      for (final tone in PxDsAlertTone.values) {
        await tester.pumpWidget(themed(PxDsAlert(tone: tone, title: 'T')));
        final urgent = tone == PxDsAlertTone.warning || tone == PxDsAlertTone.danger;
        expect(tester.getSemantics(find.byType(PxDsAlert)), containsSemantics(isLiveRegion: urgent), reason: '$tone');
      }
      handle.dispose();
    });

    testWidgets('defaults the title to the tone name', (tester) async {
      await tester.pumpWidget(themed(const PxDsAlert(tone: PxDsAlertTone.danger)));
      expect(find.text('Error'), findsOneWidget);
    });
  });

  group('PxDsIcon', () {
    test('every icon has an outline inside the 256 grid', () {
      for (final icon in PxDsIcons.all) {
        final b = icon.path.getBounds();
        expect(b.width, greaterThan(50), reason: icon.name);
        expect(b.left >= -1 && b.top >= -1 && b.right <= 257 && b.bottom <= 257, isTrue, reason: '${icon.name} $b');
      }
    });

    testWidgets('is decorative unless it has a label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(themed(const Row(children: [PxDsIcon(PxDsIcons.trash, semanticLabel: 'Delete'), PxDsIcon(PxDsIcons.info)])));
      expect(find.bySemanticsLabel('Delete'), findsOneWidget);
      handle.dispose();
    });
  });

  testWidgets('a clear error when the theme extensions are missing', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PxDsCard(title: 'x')));
    expect(tester.takeException(), isA<FlutterError>().having((e) => e.message, 'message', contains('PxDsTheme.extensions')));
  });
}
