import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:px_ds/px_ds.dart';

import 'support.dart';

/// A tall test screen: the large figure is 440 dp plus the controls.
void _tall(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Widget _body({
  Set<PxDsBodyRegion> selected = const {},
  ValueChanged<Set<PxDsBodyRegion>>? onChanged,
  bool multiple = true,
  PxDsBodyFace face = PxDsBodyFace.front,
  PxDsBodyLayout layout = PxDsBodyLayout.switcher,
  PxDsBodySize? size,
  Map<PxDsBodyRegion, String> labels = const {},
  Map<PxDsBodyRegion, String> labelSemantics = const {},
  Set<PxDsBodyRegion> disabled = const {},
  String? error,
  PxDsBodyStrings strings = PxDsBodyStrings.en,
}) =>
    themed(SingleChildScrollView(
      child: PxDsBodyOutline(
        label: 'Where does it hurt?',
        selected: selected,
        onChanged: onChanged,
        multiple: multiple,
        face: face,
        layout: layout,
        size: size,
        labels: labels,
        labelSemantics: labelSemantics,
        disabledRegions: disabled,
        error: error,
        strings: strings,
      ),
    ));

/// The screen position of [r]'s label point on the figure drawn at [height].
Offset _at(WidgetTester tester, PxDsBodyRegion r, {double height = 440}) {
  final box = tester.getTopLeft(find.byWidgetPredicate((w) => w is CustomPaint && w.size.height == height).first);
  return box + r.labelPoint * (height / pxDsBodyViewBox.height);
}

void main() {
  testWidgets('tapping a region selects it; tapping it again clears it', (tester) async {
    _tall(tester);
    var selected = <PxDsBodyRegion>{};
    await tester.pumpWidget(StatefulBuilder(builder: (context, set) => _body(selected: selected, onChanged: (s) => set(() => selected = s))));
    await tester.tapAt(_at(tester, PxDsBodyRegion.kneeLeftFront));
    await tester.pump();
    expect(selected, {PxDsBodyRegion.kneeLeftFront});
    await tester.tapAt(_at(tester, PxDsBodyRegion.chestRightFront));
    await tester.pump();
    expect(selected, {PxDsBodyRegion.kneeLeftFront, PxDsBodyRegion.chestRightFront});
    await tester.tapAt(_at(tester, PxDsBodyRegion.kneeLeftFront));
    await tester.pump();
    expect(selected, {PxDsBodyRegion.chestRightFront});
  });

  testWidgets("sides are the person's own: the viewer's left on the front is the right knee", (tester) async {
    _tall(tester);
    Set<PxDsBodyRegion>? got;
    await tester.pumpWidget(_body(onChanged: (s) => got = s));
    final box = tester.getTopLeft(find.byWidgetPredicate((w) => w is CustomPaint && w.size.height == 440).first);
    await tester.tapAt(box + const Offset(81, 333) * 1.0); // viewer's left of the midline, at knee height
    await tester.pump();
    expect(got, {PxDsBodyRegion.kneeRightFront});
  });

  testWidgets('single choice replaces the selection', (tester) async {
    _tall(tester);
    Set<PxDsBodyRegion>? got;
    await tester.pumpWidget(_body(multiple: false, selected: {PxDsBodyRegion.kneeLeftFront}, onChanged: (s) => got = s));
    await tester.tapAt(_at(tester, PxDsBodyRegion.chestRightFront));
    await tester.pump();
    expect(got, {PxDsBodyRegion.chestRightFront});
  });

  testWidgets('a tap just outside the outline goes to the nearest region within 8 dp, further away does nothing', (tester) async {
    _tall(tester);
    Set<PxDsBodyRegion>? got;
    await tester.pumpWidget(_body(onChanged: (s) => got = s));
    final box = tester.getTopLeft(find.byWidgetPredicate((w) => w is CustomPaint && w.size.height == 440).first);
    final head = PxDsBodyRegion.headFront.path.getBounds();
    await tester.tapAt(box + Offset(head.center.dx, head.top - 5));
    await tester.pump();
    expect(got, {PxDsBodyRegion.headFront});
    got = null;
    await tester.tapAt(box + Offset(head.center.dx, head.top - 30));
    await tester.pump();
    expect(got, isNull);
  });

  testWidgets('a disabled region can not be selected', (tester) async {
    _tall(tester);
    Set<PxDsBodyRegion>? got;
    await tester.pumpWidget(_body(disabled: {PxDsBodyRegion.kneeLeftFront}, onChanged: (s) => got = s));
    await tester.tapAt(_at(tester, PxDsBodyRegion.kneeLeftFront));
    await tester.pump();
    expect(got, isNull);
  });

  testWidgets('the face toggle shows the back; selections on both faces stay in the summary', (tester) async {
    _tall(tester);
    var selected = <PxDsBodyRegion>{PxDsBodyRegion.kneeLeftFront};
    await tester.pumpWidget(StatefulBuilder(builder: (context, set) => _body(selected: selected, onChanged: (s) => set(() => selected = s))));
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    await tester.tapAt(_at(tester, PxDsBodyRegion.calfLeftBack));
    await tester.pump();
    expect(selected, {PxDsBodyRegion.kneeLeftFront, PxDsBodyRegion.calfLeftBack});
    expect(find.text('Selected: Left knee, front; Left calf'), findsOneWidget);
  });

  testWidgets('the summary says "No areas selected", and shortens to 3 names and "and N more" past 4', (tester) async {
    _tall(tester);
    await tester.pumpWidget(_body(onChanged: (_) {}));
    expect(find.text('No areas selected'), findsOneWidget);
    await tester.pumpWidget(_body(onChanged: (_) {}, selected: {
      PxDsBodyRegion.headFront,
      PxDsBodyRegion.neckFront,
      PxDsBodyRegion.shoulderRightFront,
      PxDsBodyRegion.shoulderLeftFront,
      PxDsBodyRegion.chestRightFront,
    }));
    expect(find.text('Selected: Head, front; Neck, front; Right shoulder, front; and 2 more'), findsOneWidget);
  });

  testWidgets('display-only: no taps, "No areas recorded", regions read as text with their label', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_body());
    expect(find.text('No areas recorded'), findsOneWidget);
    await tester.pumpWidget(_body(
      selected: {PxDsBodyRegion.kneeLeftFront},
      labels: {PxDsBodyRegion.kneeLeftFront: '7/10'},
      labelSemantics: {PxDsBodyRegion.kneeLeftFront: '7 out of 10'},
    ));
    expect(find.text('7/10'), findsOneWidget);
    expect(find.bySemanticsLabel('Left knee, front, 7 out of 10'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('select mode: each region is a button with a selected state', (tester) async {
    _tall(tester);
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_body(onChanged: (_) {}, selected: {PxDsBodyRegion.kneeLeftFront}));
    final knee = tester.getSemantics(find.bySemanticsLabel('Left knee, front'));
    expect(knee, isSemantics(isButton: true, isSelected: true, isFocusable: true, hasTapAction: true));
    expect(tester.getSemantics(find.bySemanticsLabel('Right knee, front')), isSemantics(isButton: true, isSelected: false));
    handle.dispose();
  });

  testWidgets('keyboard: Tab goes through the regions head to foot, Space toggles', (tester) async {
    _tall(tester);
    Set<PxDsBodyRegion>? got;
    await tester.pumpWidget(_body(onChanged: (s) => got = s));
    // Order: the two face buttons, then head, neck, ...
    for (var i = 0; i < 3; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'PxDsBodyOutline head-front');
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'PxDsBodyOutline neck-front');
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(got, {PxDsBodyRegion.neckFront});
  });

  testWidgets('"Choose from a list" shows the same regions as checkboxes bound to the selection', (tester) async {
    _tall(tester);
    var selected = <PxDsBodyRegion>{};
    await tester.pumpWidget(StatefulBuilder(builder: (context, set) => _body(selected: selected, onChanged: (s) => set(() => selected = s))));
    await tester.tap(find.text('Choose from a list'));
    await tester.pumpAndSettle();
    expect(find.text('Head and neck'), findsOneWidget);
    expect(find.byType(PxDsCheckbox), findsNWidgets(PxDsBodyRegion.values.length));
    await tester.ensureVisible(find.text('Left calf'));
    await tester.tap(find.text('Left calf'));
    await tester.pump();
    expect(selected, {PxDsBodyRegion.calfLeftBack});
    expect(find.text('Show the figure'), findsOneWidget);
  });

  testWidgets('side by side shows both faces without a toggle', (tester) async {
    _tall(tester);
    await tester.pumpWidget(_body(layout: PxDsBodyLayout.sideBySide, size: PxDsBodySize.medium));
    expect(find.text('Front'), findsNothing);
    expect(find.byWidgetPredicate((w) => w is CustomPaint && w.size.height == 320), findsNWidgets(2));
  });

  testWidgets('an error shows words and the icon', (tester) async {
    _tall(tester);
    await tester.pumpWidget(_body(onChanged: (_) {}, error: 'Choose at least one area.'));
    expect(find.text('Choose at least one area.'), findsOneWidget);
    expect(find.byType(PxDsIcon), findsOneWidget);
  });

  testWidgets('Spanish (Chile) strings and region names', (tester) async {
    _tall(tester);
    await tester.pumpWidget(_body(onChanged: (_) {}, strings: PxDsBodyStrings.esCl, selected: {PxDsBodyRegion.kneeLeftFront}));
    expect(find.text('Seleccionadas: Rodilla izquierda, parte delantera'), findsOneWidget);
    expect(find.text('Espalda'), findsOneWidget);
  });

  testWidgets('selecting needs the large size', (tester) async {
    _tall(tester);
    await tester.pumpWidget(_body(onChanged: (_) {}, size: PxDsBodySize.small));
    expect(tester.takeException(), isA<AssertionError>());
  });
}
