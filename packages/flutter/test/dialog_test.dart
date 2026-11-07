import 'dart:ui' show SemanticsRole;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:px_ds/px_ds.dart';

import 'support.dart';

void main() {
  Future<String?> open(WidgetTester tester, {bool alert = false}) async {
    String? result = 'not closed';
    await tester.pumpWidget(themed(Builder(
      builder: (context) => PxDsButton(
        label: 'Open',
        onPressed: () async {
          result = await showPxDsDialog<String>(
            context: context,
            title: 'Delete this entry?',
            message: 'You can\'t undo this.',
            alert: alert,
            actions: [
              Builder(builder: (context) => PxDsButton(label: 'Keep entry', variant: PxDsButtonVariant.ghost, onPressed: () => Navigator.pop(context, 'keep'))),
              Builder(builder: (context) => PxDsButton(label: 'Delete entry', variant: PxDsButtonVariant.danger, onPressed: () => Navigator.pop(context, 'delete'))),
            ],
          );
        },
      ),
    )));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('an action closes it with its result', (tester) async {
    String? result;
    await tester.pumpWidget(themed(Builder(
      builder: (context) => PxDsButton(
        label: 'Open',
        onPressed: () async {
          result = await showPxDsDialog<String>(
            context: context,
            title: 'Delete this entry?',
            actions: [Builder(builder: (context) => PxDsButton(label: 'Delete entry', onPressed: () => Navigator.pop(context, 'delete')))],
          );
        },
      ),
    )));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this entry?'), findsOneWidget);
    await tester.tap(find.text('Delete entry'));
    await tester.pumpAndSettle();
    expect(result, 'delete');
    expect(find.byType(PxDsDialog), findsNothing);
  });

  testWidgets('names the route, marks the title as a heading and draws the scrim', (tester) async {
    final handle = tester.ensureSemantics();
    await open(tester);
    expect(tester.getSemantics(find.text('Delete this entry?')), isSemantics(isHeader: true));
    expect(
      find.byWidgetPredicate((w) => w is Semantics && w.properties.scopesRoute == true && w.properties.namesRoute == true && w.properties.label == 'Delete this entry?'),
      findsOneWidget,
    );
    final barrier = tester.widget<ModalBarrier>(find.byType(ModalBarrier).last);
    expect(barrier.color, PxDsColors.pxLight.colorScrim);
    handle.dispose();
  });

  testWidgets('the close button, Esc and the backdrop dismiss it', (tester) async {
    await open(tester);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(PxDsDialog), findsNothing);

    await open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(PxDsDialog), findsNothing);

    await open(tester);
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(find.byType(PxDsDialog), findsNothing);
  });

  testWidgets('an alert dialog has no close button and ignores the backdrop', (tester) async {
    await open(tester, alert: true);
    expect(find.byTooltip('Close'), findsNothing);
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(find.byType(PxDsDialog), findsOneWidget);
    expect(
      find.byWidgetPredicate((w) => w is Semantics && w.properties.role == SemanticsRole.alertDialog),
      findsOneWidget,
    );
  });

  testWidgets('fits a small phone: 16 from the edges, body scrolls', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(themed(Builder(
      builder: (context) => PxDsButton(
        label: 'Open',
        onPressed: () => showPxDsDialog<void>(context: context, title: 'Terms', body: Text('Long text. ' * 400)),
      ),
    )));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final panel = tester.getRect(find.byType(PxDsDialog).first);
    expect(panel.left, greaterThanOrEqualTo(0));
    expect(find.byType(SingleChildScrollView), findsWidgets);
  });
}
