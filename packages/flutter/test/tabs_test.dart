import 'dart:ui' show SemanticsRole;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:px_ds/px_ds.dart';

import 'support.dart';

Widget _tabs({int initialIndex = 0, ValueChanged<int>? onChanged, bool middleEnabled = true, TextDirection dir = TextDirection.ltr}) => themed(
      Directionality(
        textDirection: dir,
        child: PxDsTabs(
        label: 'Views',
        initialIndex: initialIndex,
        onChanged: onChanged,
        tabs: [
          const PxDsTab(label: 'List', content: Text('list content')),
          PxDsTab(label: 'Chart', content: const Text('chart content'), enabled: middleEnabled),
          const PxDsTab(label: 'Body', content: Text('body content')),
        ],
      ),
    ));

void main() {
  testWidgets('shows the first tab and only its content', (tester) async {
    await tester.pumpWidget(_tabs());
    expect(find.text('list content'), findsOneWidget);
    expect(find.text('chart content'), findsNothing);
  });

  testWidgets('tapping a tab selects it and reports the index', (tester) async {
    int? changed;
    await tester.pumpWidget(_tabs(onChanged: (i) => changed = i));
    await tester.tap(find.text('Body'));
    await tester.pump();
    expect(find.text('body content'), findsOneWidget);
    expect(find.text('list content'), findsNothing);
    expect(changed, 2);
  });

  testWidgets('a disabled tab can not be selected', (tester) async {
    await tester.pumpWidget(_tabs(middleEnabled: false));
    await tester.tap(find.text('Chart'));
    await tester.pump();
    expect(find.text('list content'), findsOneWidget);
  });

  testWidgets('a disabled initial tab falls back to the next enabled one', (tester) async {
    await tester.pumpWidget(_tabs(initialIndex: 1, middleEnabled: false));
    expect(find.text('body content'), findsOneWidget);
  });

  testWidgets('keyboard: Tab enters at the selected tab; arrows, Home and End move and select', (tester) async {
    await tester.pumpWidget(_tabs());
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.text('chart content'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    expect(find.text('body content'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight); // wraps round
    await tester.pumpAndSettle();
    expect(find.text('list content'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(find.text('body content'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expect(find.text('list content'), findsOneWidget);
  });

  testWidgets('keyboard skips a disabled tab', (tester) async {
    await tester.pumpWidget(_tabs(middleEnabled: false));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.text('body content'), findsOneWidget);
  });

  testWidgets('right-to-left swaps the arrow keys', (tester) async {
    await tester.pumpWidget(_tabs(dir: TextDirection.rtl));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(find.text('chart content'), findsOneWidget);
  });

  testWidgets('only the selected tab is a Tab stop', (tester) async {
    await tester.pumpWidget(themed(PxDsTabs(label: 'Views', tabs: [
      PxDsTab(label: 'List', content: TextButton(onPressed: () {}, child: const Text('in panel'))),
      const PxDsTab(label: 'Chart', content: Text('chart content')),
    ])));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'PxDsTabs tab 0');
    await tester.sendKeyEvent(LogicalKeyboardKey.tab); // leaves the list, not on to the next tab
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.debugLabel, isNot(contains('PxDsTabs tab')));
  });

  testWidgets('semantics: a named tab bar, tabs with the selected state, and a panel', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_tabs());
    final bar = tester.getSemantics(find.bySemanticsLabel('Views')).getSemanticsData();
    expect(bar.role, SemanticsRole.tabBar);
    final list = tester.getSemantics(find.text('List'));
    expect(list, isSemantics(isSelected: true));
    expect(list.getSemanticsData().role, SemanticsRole.tab);
    expect(tester.getSemantics(find.text('Body')), isSemantics(isSelected: false));
    expect(tester.getSemantics(find.text('list content')).getSemanticsData().role, SemanticsRole.tabPanel);
    handle.dispose();
  });

  testWidgets('the selected tab is marked by an underline, not only by colour', (tester) async {
    await tester.pumpWidget(_tabs());
    Border borderOf(String label) {
      final box = tester.widget<Container>(find.ancestor(of: find.text(label), matching: find.byType(Container)).first);
      return (box.decoration! as BoxDecoration).border! as Border;
    }

    expect(borderOf('List').bottom.width, PxDsTokens.borderWidthThick);
    expect(borderOf('List').bottom.color, PxDsColors.pxLight.colorTextLink);
    expect(borderOf('Body').bottom.color, Colors.transparent);
  });
}
