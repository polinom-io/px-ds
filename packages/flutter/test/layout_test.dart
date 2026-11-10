import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:px_ds/px_ds.dart';

import 'support.dart';

/// Lays [child] out in a box [width] wide, on a test screen wide enough to hold it.
Future<void> _pump(WidgetTester tester, double width, Widget child) {
  tester.view.physicalSize = const Size(1600, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(_sized(width, child));
}

Widget _sized(double width, Widget child) => MaterialApp(
      theme: ThemeData(extensions: PxDsTheme.extensions(PxDsBrand.px, Brightness.light)),
      home: Scaffold(body: Align(alignment: Alignment.topLeft, child: SizedBox(width: width, child: child))),
    );

Widget _cell(String key) => SizedBox(key: ValueKey(key), height: 20);

void main() {
  group('PxDsBox', () {
    testWidgets('pads by token and paints the surface, border and radius', (tester) async {
      await tester.pumpWidget(themed(const PxDsBox(
        padding: PxDsSpace.s4,
        paddingY: PxDsSpace.s2,
        surface: PxDsSurface.sunken,
        bordered: true,
        radius: PxDsRadius.lg,
        child: SizedBox(key: ValueKey('c'), width: 10, height: 10),
      )));
      final padding = tester.widget<Padding>(find.ancestor(of: find.byKey(const ValueKey('c')), matching: find.byType(Padding)).first);
      expect(padding.padding, const EdgeInsets.symmetric(horizontal: 16, vertical: 8));
      final deco = tester.widget<DecoratedBox>(find.byType(DecoratedBox).last).decoration as BoxDecoration;
      expect(deco.color, PxDsColors.pxLight.colorSurfaceSunken);
      expect(deco.borderRadius, BorderRadius.circular(PxDsTokens.radiusLg));
      expect(deco.border, isNotNull);
    });

    testWidgets('adds no decoration when it has none to paint', (tester) async {
      await tester.pumpWidget(themed(const PxDsBox(padding: PxDsSpace.s2, child: Text('x'))));
      expect(find.descendant(of: find.byType(PxDsBox), matching: find.byType(DecoratedBox)), findsNothing);
    });
  });

  group('PxDsStack', () {
    testWidgets('puts the token gap between children, vertical and horizontal', (tester) async {
      await tester.pumpWidget(themed(const PxDsStack(gap: PxDsSpace.s3, children: [_Box('a'), _Box('b')])));
      expect(tester.getTopLeft(find.byKey(const ValueKey('b'))).dy - tester.getBottomLeft(find.byKey(const ValueKey('a'))).dy, 12);
      await tester.pumpWidget(themed(const PxDsStack.horizontal(gap: PxDsSpace.s6, children: [_Box('a'), _Box('b')])));
      expect(tester.getTopLeft(find.byKey(const ValueKey('b'))).dx - tester.getTopRight(find.byKey(const ValueKey('a'))).dx, 24);
    });

    testWidgets('wrap flows onto a new line with the same gap', (tester) async {
      await _pump(tester, 110, const PxDsStack.horizontal(gap: PxDsSpace.s2, wrap: true, children: [_Box('a'), _Box('b'), _Box('c')]));
      final a = tester.getRect(find.byKey(const ValueKey('a')));
      final b = tester.getRect(find.byKey(const ValueKey('b')));
      expect(b.top - a.bottom, 8);
      expect(b.left, a.left);
    });
  });

  group('PxDsGrid', () {
    testWidgets('uses 4, 8 and 12 columns by its own width', (tester) async {
      expect(PxDsGrid.columnsFor(639), 4);
      expect(PxDsGrid.columnsFor(768), 8);
      expect(PxDsGrid.columnsFor(1023), 8);
      expect(PxDsGrid.columnsFor(1024), 12);
    });

    testWidgets('responsive spans: a half-width cell on 12 columns, full on 4', (tester) async {
      Widget grid() => PxDsGrid(children: [
            PxDsGridItem(span: 4, spanMd: 4, spanLg: 6, child: _cell('a')),
            PxDsGridItem(span: 4, spanMd: 4, spanLg: 6, child: _cell('b')),
          ]);
      await _pump(tester, 1200, grid());
      // 12 columns, gutter 24: a column is (1200 - 11 * 24) / 12 = 78; six of them 6 * 78 + 5 * 24 = 588.
      expect(tester.getSize(find.byKey(const ValueKey('a'))).width, closeTo(588, 0.01));
      expect(tester.getTopLeft(find.byKey(const ValueKey('b'))).dx, closeTo(588 + 24, 0.01));
      await _pump(tester, 400, grid());
      // 4 columns: each cell is full width, so the second wraps below with a 16 gutter.
      expect(tester.getSize(find.byKey(const ValueKey('a'))).width, 400);
      expect(tester.getTopLeft(find.byKey(const ValueKey('b'))).dy - tester.getBottomLeft(find.byKey(const ValueKey('a'))).dy, 16);
    });

    testWidgets('a span larger than the columns is clamped, a cell without a span takes the row', (tester) async {
      await _pump(tester, 400, PxDsGrid(children: [
        PxDsGridItem(span: 9, child: _cell('a')),
        PxDsGridItem(child: _cell('b')),
      ]));
      expect(tester.getSize(find.byKey(const ValueKey('a'))).width, 400);
      expect(tester.getSize(find.byKey(const ValueKey('b'))).width, 400);
      expect(tester.takeException(), isNull);
    });
  });

  group('PxDsContainer', () {
    testWidgets('centres at the maximum width with side padding', (tester) async {
      await _pump(tester, 1600, const PxDsContainer(child: _Box('c', width: 2000)));
      // The 1600 box holds a 1200 container, centred.
      final rect = tester.getRect(find.descendant(of: find.byType(PxDsContainer), matching: find.byType(ConstrainedBox)).first);
      expect(rect.width, 1200);
      expect(rect.left, 200);
    });

    testWidgets('sm is 640 wide, and narrow screens use the smaller side padding', (tester) async {
      await _pump(tester, 500, const PxDsContainer(size: PxDsContainerSize.sm, child: _Box('c', width: 10)));
      expect(tester.getTopLeft(find.byKey(const ValueKey('c'))).dx, 16);
    });
  });

  group('PxDsDivider', () {
    testWidgets('a horizontal rule is a hairline, and is not in semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(themed(const PxDsDivider()));
      expect(tester.getSize(find.byType(PxDsDivider)).height, 1);
      expect(find.bySemanticsLabel(RegExp('.')), findsNothing);
      handle.dispose();
    });

    testWidgets('a label is shown and read', (tester) async {
      await tester.pumpWidget(themed(const PxDsDivider(label: 'or')));
      expect(find.text('or'), findsOneWidget);
    });

    testWidgets('a vertical divider is one hairline wide', (tester) async {
      await tester.pumpWidget(themed(const SizedBox(height: 40, child: Row(children: [PxDsDivider(axis: Axis.vertical)]))));
      expect(tester.getSize(find.byType(PxDsDivider)), const Size(1, 40));
    });
  });

  testWidgets('PxDsVisuallyHidden is read by screen readers and paints nothing', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(themed(const Row(children: [Text('★'), PxDsVisuallyHidden('Required')])));
    expect(find.bySemanticsLabel('Required'), findsOneWidget);
    expect(tester.getSize(find.byType(PxDsVisuallyHidden)), const Size(1, 1));
    handle.dispose();
  });
}

class _Box extends StatelessWidget {
  const _Box(this.id, {this.width = 100});
  final String id;
  final double width;
  @override
  Widget build(BuildContext context) => SizedBox(key: ValueKey(id), width: width, height: 20);
}
