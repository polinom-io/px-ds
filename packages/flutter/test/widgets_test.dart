import 'dart:ui' show SemanticsValidationResult;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:px_ds/px_ds.dart';
import 'package:px_ds/src/widgets/selection_row.dart';

import 'support.dart';

void main() {
  group('PxDsButton', () {
    testWidgets('calls onPressed and exposes a button with its label', (tester) async {
      var taps = 0;
      await tester.pumpWidget(themed(PxDsButton(label: 'Save changes', onPressed: () => taps++)));
      await tester.tap(find.text('Save changes'));
      expect(taps, 1);
      expect(tester.getSemantics(find.byType(TextButton)), isSemantics(label: 'Save changes', isButton: true, isEnabled: true, hasTapAction: true));
    });

    testWidgets('null onPressed is disabled and faded', (tester) async {
      await tester.pumpWidget(themed(const PxDsButton(label: 'Save', onPressed: null)));
      expect(tester.getSemantics(find.byType(TextButton)), isSemantics(isButton: true, isEnabled: false));
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
      expect(node, isSemantics(isTextField: true));
      expect(node, isSemantics(validationResult: SemanticsValidationResult.invalid));
      expect(node.getSemanticsData().label, contains('Enter a valid email address.'));
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(find.byType(PxDsIcon), findsOneWidget); // the error has an icon, not colour alone
      handle.dispose();
    });

    testWidgets('a field without an error is not marked invalid, and reads its helper', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(themed(const PxDsTextField(label: 'Name', helper: 'As on your ID')));
      final node = tester.getSemantics(find.byType(TextField));
      expect(node, isSemantics(validationResult: SemanticsValidationResult.none));
      expect(node.getSemanticsData().label, contains('As on your ID'));
      handle.dispose();
    });

    testWidgets('shows the helper only when there is no error', (tester) async {
      await tester.pumpWidget(themed(const PxDsTextField(label: 'Name', helper: 'As on your ID')));
      expect(find.text('As on your ID'), findsOneWidget);
      await tester.pumpWidget(themed(const PxDsTextField(label: 'Name', helper: 'As on your ID', error: 'Required')));
      await tester.pumpAndSettle();
      expect(find.text('As on your ID'), findsNothing);
      expect(find.text('Required'), findsOneWidget);
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
    expect(tester.getSemantics(find.text('Strategy')), isSemantics(isHeader: true));
    handle.dispose();
  });

  group('PxDsAlert', () {
    testWidgets('warning and danger are live regions; info and success are not', (tester) async {
      final handle = tester.ensureSemantics();
      for (final tone in PxDsAlertTone.values) {
        await tester.pumpWidget(themed(PxDsAlert(tone: tone, title: 'T')));
        final urgent = tone == PxDsAlertTone.warning || tone == PxDsAlertTone.danger;
        expect(tester.getSemantics(find.byType(PxDsAlert)), isSemantics(isLiveRegion: urgent), reason: '$tone');
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
      // getBounds() includes curve control points, which sit outside the outline, so trace the
      // outline itself and take the bounds of the points on it.
      for (final icon in PxDsIcons.all) {
        var minX = double.infinity, minY = double.infinity, maxX = -double.infinity, maxY = -double.infinity;
        for (final metric in icon.path.computeMetrics()) {
          for (var d = 0.0; d <= metric.length; d += 0.5) {
            final p = metric.getTangentForOffset(d)!.position;
            minX = p.dx < minX ? p.dx : minX; minY = p.dy < minY ? p.dy : minY;
            maxX = p.dx > maxX ? p.dx : maxX; maxY = p.dy > maxY ? p.dy : maxY;
          }
        }
        final b = Rect.fromLTRB(minX, minY, maxX, maxY);
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

  group('PxDsSwitch', () {
    testWidgets('toggles on tap anywhere on the row and reads as on/off', (tester) async {
      final handle = tester.ensureSemantics();
      var value = false;
      await tester.pumpWidget(themed(StatefulBuilder(
        builder: (context, set) => PxDsSwitch(label: 'Reminders', value: value, onChanged: (v) => set(() => value = v)),
      )));
      expect(tester.getSemantics(find.byType(PxDsSwitch)), isSemantics(label: 'Reminders', hasToggledState: true, isToggled: false, isEnabled: true, hasTapAction: true));
      await tester.tap(find.text('Reminders'));
      await tester.pumpAndSettle();
      expect(value, isTrue);
      expect(tester.getSemantics(find.byType(PxDsSwitch)), isSemantics(hasToggledState: true, isToggled: true));
      handle.dispose();
    });

    testWidgets('Space toggles it when focused', (tester) async {
      var value = false;
      await tester.pumpWidget(themed(StatefulBuilder(
        builder: (context, set) => PxDsSwitch(label: 'Reminders', value: value, onChanged: (v) => set(() => value = v)),
      )));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(value, isTrue);
    });

    testWidgets('the row is at least 48 tall and null onChanged disables it', (tester) async {
      await tester.pumpWidget(themed(const Align(alignment: Alignment.topLeft, child: PxDsSwitch(label: 'Off', value: false, onChanged: null))));
      expect(tester.getSize(find.byType(PxDsSwitch)).height, greaterThanOrEqualTo(48));
      await tester.tap(find.text('Off'), warnIfMissed: false);
      expect(find.byType(Opacity), findsOneWidget);
    });
  });

  group('PxDsCheckbox', () {
    testWidgets('checks on tap and exposes the checked state', (tester) async {
      final handle = tester.ensureSemantics();
      bool? value = false;
      await tester.pumpWidget(themed(StatefulBuilder(
        builder: (context, set) => PxDsCheckbox(label: 'I agree', value: value, onChanged: (v) => set(() => value = v)),
      )));
      expect(tester.getSemantics(find.byType(PxDsCheckbox)), isSemantics(label: 'I agree', hasCheckedState: true, isChecked: false));
      await tester.tap(find.text('I agree'));
      await tester.pump();
      expect(value, isTrue);
      expect(tester.getSemantics(find.byType(PxDsCheckbox)), isSemantics(hasCheckedState: true, isChecked: true));
      handle.dispose();
    });

    testWidgets('indeterminate shows a minus, reads as mixed, and checks on tap', (tester) async {
      final handle = tester.ensureSemantics();
      bool? value;
      await tester.pumpWidget(themed(StatefulBuilder(
        builder: (context, set) => PxDsCheckbox(label: 'Select all', value: value, tristate: true, onChanged: (v) => set(() => value = v)),
      )));
      expect(tester.widget<PxDsIcon>(find.byType(PxDsIcon)).icon, PxDsIcons.minus);
      expect(tester.getSemantics(find.byType(PxDsCheckbox)), isSemantics(hasCheckedState: true, isCheckStateMixed: true));
      await tester.tap(find.text('Select all'));
      await tester.pump();
      expect(value, isTrue);
      handle.dispose();
    });

    testWidgets('an error has an icon and is read with the label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(themed(PxDsCheckbox(label: 'Accept the terms', value: false, error: 'Accept the terms to continue.', onChanged: (_) {})));
      expect(find.text('Accept the terms to continue.'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is PxDsIcon && w.icon == PxDsIcons.xCircle), findsOneWidget);
      expect(tester.getSemantics(find.byType(PxDsSelectionRow)).getSemanticsData().label, 'Accept the terms, Accept the terms to continue.');
      handle.dispose();
    });
  });

  group('PxDsRadioGroup', () {
    Widget group(String? initial, {void Function(String)? spy}) {
      var value = initial;
      return themed(StatefulBuilder(
        builder: (context, set) => PxDsRadioGroup<String>(
          label: 'How often?',
          value: value,
          onChanged: (v) => set(() {
            value = v;
            spy?.call(v);
          }),
          options: const [
            PxDsRadioOption(value: 'daily', label: 'Every day'),
            PxDsRadioOption(value: 'weekly', label: 'Every week'),
            PxDsRadioOption(value: 'monthly', label: 'Every month', enabled: false),
            PxDsRadioOption(value: 'never', label: 'Never'),
          ],
        ),
      ));
    }

    testWidgets('selects on tap; options are checked radios in one group', (tester) async {
      final handle = tester.ensureSemantics();
      String? picked;
      await tester.pumpWidget(group(null, spy: (v) => picked = v));
      await tester.tap(find.text('Every week'));
      await tester.pump();
      expect(picked, 'weekly');
      expect(tester.getSemantics(find.text('Every week')), isSemantics(hasCheckedState: true, isChecked: true, isInMutuallyExclusiveGroup: true));
      expect(tester.getSemantics(find.text('Every day')), isSemantics(hasCheckedState: true, isChecked: false, isInMutuallyExclusiveGroup: true));
      expect(find.bySemanticsLabel('How often?'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('Tab lands on the selected option; arrows move and select, skipping disabled', (tester) async {
      String? picked;
      await tester.pumpWidget(group('weekly', spy: (v) => picked = v));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final focused = FocusManager.instance.primaryFocus!;
      expect(focused.debugLabel, 'PxDsRadioGroup option 1');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(picked, 'never'); // 'monthly' is disabled
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(picked, 'daily'); // wraps
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(picked, 'never');
    });
  });

  testWidgets('a clear error when the theme extensions are missing', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PxDsCard(title: 'x')));
    expect(tester.takeException(), isA<FlutterError>().having((e) => e.message, 'message', contains('PxDsTheme.extensions')));
  });
}
