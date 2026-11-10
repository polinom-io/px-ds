import 'dart:ui' show SemanticsValidationResult, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:px_ds/px_ds.dart';

import 'support.dart';

const _options = [
  PxDsSelectOption(value: 'low', label: 'Low'),
  PxDsSelectOption(value: 'mid', label: 'Medium'),
  PxDsSelectOption(value: 'off', label: 'Unavailable', enabled: false),
];

Widget _select({String? value, ValueChanged<String>? onChanged, String? error, String? helper, bool required = false, bool enabled = true}) => themed(
      PxDsSelect<String>(
        label: 'Intensity',
        placeholder: 'Choose one',
        options: _options,
        value: value,
        onChanged: onChanged ?? (_) {},
        error: error,
        helper: helper,
        required: required,
        enabled: enabled,
      ),
    );

void main() {
  testWidgets('shows the placeholder until something is picked, then the picked label', (tester) async {
    await tester.pumpWidget(_select());
    expect(find.text('Choose one'), findsOneWidget);
    await tester.pumpWidget(_select(value: 'mid'));
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('Choose one'), findsNothing);
  });

  testWidgets('opens on tap, picks an option and closes', (tester) async {
    String? picked;
    await tester.pumpWidget(_select(onChanged: (v) => picked = v));
    expect(find.text('Low'), findsNothing);
    await tester.tap(find.text('Choose one'));
    await tester.pumpAndSettle();
    expect(find.text('Low'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    await tester.tap(find.text('Medium'));
    await tester.pumpAndSettle();
    expect(picked, 'mid');
    expect(find.text('Low'), findsNothing);
  });

  testWidgets('a disabled option is listed but can not be picked', (tester) async {
    String? picked;
    await tester.pumpWidget(_select(onChanged: (v) => picked = v));
    await tester.tap(find.text('Choose one'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unavailable'));
    await tester.pumpAndSettle();
    expect(picked, isNull);
  });

  testWidgets('the picked option carries a check, not only its position', (tester) async {
    await tester.pumpWidget(_select(value: 'low'));
    await tester.tap(find.text('Low'));
    await tester.pumpAndSettle();
    // The check icon is in the list next to the picked option, besides the caret in the field.
    expect(find.byType(PxDsIcon), findsNWidgets(2));
  });

  testWidgets('keyboard: Enter on the focused field opens it, Escape closes it', (tester) async {
    await tester.pumpWidget(_select());
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Low'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Low'), findsNothing);
  });

  testWidgets('keyboard: arrow down opens it', (tester) async {
    await tester.pumpWidget(_select());
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(find.text('Low'), findsOneWidget);
  });

  testWidgets('one semantics node: label, required, value and error, as a collapsed button', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_select(value: 'low', required: true, error: 'Pick an intensity.'));
    final data = tester.getSemantics(find.bySemanticsLabel('Intensity, required')).getSemanticsData();
    expect(data.value, 'Low');
    expect(data.hint, 'Pick an intensity.');
    expect(data.flagsCollection.isButton, isTrue);
    expect(data.flagsCollection.isExpanded, Tristate.isFalse);
    expect(data.validationResult, SemanticsValidationResult.invalid);
    handle.dispose();
  });

  testWidgets('an error shows words and the x-circle icon, and replaces the helper', (tester) async {
    await tester.pumpWidget(_select(helper: 'Pick the strongest.', error: 'Pick an intensity.'));
    expect(find.text('Pick an intensity.'), findsOneWidget);
    expect(find.text('Pick the strongest.'), findsNothing);
    expect(find.byType(PxDsIcon), findsNWidgets(2)); // the caret and the error icon
  });

  testWidgets('disabled does not open', (tester) async {
    await tester.pumpWidget(_select(enabled: false));
    await tester.tap(find.text('Choose one'));
    await tester.pumpAndSettle();
    expect(find.text('Low'), findsNothing);
  });
}
