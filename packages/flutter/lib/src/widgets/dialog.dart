import 'dart:ui' show SemanticsRole;

import 'package:flutter/material.dart';

import '../icons/icons.g.dart';
import '../tokens/tokens.g.dart';
import 'icon.dart';
import 'theme_access.dart';

/// Shows a [PxDsDialog] as a modal route over a color-scrim backdrop and returns what it was
/// closed with: the value an action passes to `Navigator.pop`, or null when dismissed.
///
/// * Dismissible by the close button, the system back gesture, Esc and a tap on the backdrop,
///   except with [alert], which only closes through its actions.
/// * Focus moves into the dialog and returns to what opened it when it closes; the page behind is
///   hidden from screen readers.
Future<T?> showPxDsDialog<T>({
  required BuildContext context,
  required String title,
  Widget? body,
  String? message,
  List<Widget> actions = const [],
  bool alert = false,
}) {
  final c = PxDsThemeData.of(context).colors;
  return showDialog<T>(
    context: context,
    barrierColor: c.colorScrim,
    barrierDismissible: !alert,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    builder: (context) => PxDsDialog(title: title, message: message, actions: actions, alert: alert, child: body),
  );
}

/// Modal / Dialog (OVL-01), including the Alert dialog variant. Usually shown with
/// [showPxDsDialog]; the widget itself is the panel only.
///
/// * [title] is phrased as the question or the task ("Delete this entry?") and names the dialog
///   for screen readers.
/// * [actions] are buttons, the safe one first; they sit at the end and stack when there is no
///   room. Each action pops the route with its result.
/// * [alert]: a decision that needs an answer (destructive or irreversible). No close button,
///   no backdrop dismiss, and screen readers announce it as an alert dialog.
/// * Panel: color-surface-overlay, hairline color-border-subtle, radius-xl, shadow-4; at most
///   560 wide with a space-4 margin to the screen edge. The body scrolls when it is too tall.
class PxDsDialog extends StatelessWidget {
  const PxDsDialog({super.key, required this.title, this.message, this.child, this.actions = const [], this.alert = false});

  final String title;

  /// Plain body text. Use [child] for anything richer.
  final String? message;
  final Widget? child;
  final List<Widget> actions;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final ds = PxDsThemeData.of(context);
    final c = ds.colors;
    final shadow = Theme.of(context).extension<PxDsElevation>()?.shadow4 ?? const <BoxShadow>[];
    const divider = BorderSide(width: PxDsTokens.borderWidthHairline);
    final rule = divider.copyWith(color: c.colorBorderSubtle);

    final head = Container(
      decoration: BoxDecoration(border: Border(bottom: rule)),
      padding: EdgeInsets.fromLTRB(PxDsTokens.space6, PxDsTokens.space4, alert ? PxDsTokens.space6 : PxDsTokens.space2, PxDsTokens.space4),
      child: Row(children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(title, style: ds.type.textTitleMd.copyWith(color: c.colorTextDefault)),
          ),
        ),
        if (!alert)
          IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            onPressed: () => Navigator.maybePop(context),
            style: IconButton.styleFrom(
              foregroundColor: c.colorTextDefault,
              minimumSize: const Size.square(PxDsTokens.sizeControlLg),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(PxDsTokens.radiusMd))),
            ).copyWith(
              side: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.focused) ? BorderSide(color: c.colorFocusRing, width: PxDsTokens.borderWidthFocus) : BorderSide.none),
              overlayColor: WidgetStateProperty.resolveWith((s) {
                if (s.contains(WidgetState.pressed)) return c.colorTextDefault.withValues(alpha: PxDsTokens.opacityStatePressed);
                if (s.contains(WidgetState.hovered)) return c.colorTextDefault.withValues(alpha: PxDsTokens.opacityStateHover);
                return null;
              }),
            ),
            icon: PxDsIcon(PxDsIcons.x, size: PxDsTokens.sizeIconMd, color: c.colorTextDefault),
          ),
      ]),
    );

    final content = Flexible(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(PxDsTokens.space6),
        child: DefaultTextStyle.merge(
          style: ds.type.textBodyMd.copyWith(color: c.colorTextDefault),
          child: child ?? Text(message ?? ''),
        ),
      ),
    );

    final foot = actions.isEmpty
        ? null
        : Container(
            decoration: BoxDecoration(border: Border(top: rule)),
            padding: const EdgeInsets.symmetric(horizontal: PxDsTokens.space6, vertical: PxDsTokens.space4),
            child: OverflowBar(
              alignment: MainAxisAlignment.end,
              overflowAlignment: OverflowBarAlignment.end,
              spacing: PxDsTokens.space3,
              overflowSpacing: PxDsTokens.space2,
              children: actions,
            ),
          );

    return Dialog(
      backgroundColor: const Color(0x00000000),
      surfaceTintColor: const Color(0x00000000),
      shadowColor: const Color(0x00000000),
      elevation: 0,
      insetPadding: const EdgeInsets.all(PxDsTokens.space4),
      child: Semantics(
        scopesRoute: true,
        namesRoute: true,
        explicitChildNodes: true,
        role: alert ? SemanticsRole.alertDialog : SemanticsRole.dialog,
        label: title,
        child: ConstrainedBox(
          // 560, as on the web package; there is no dialog-width token yet.
          constraints: const BoxConstraints(maxWidth: 560),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: c.colorSurfaceOverlay,
              borderRadius: const BorderRadius.all(Radius.circular(PxDsTokens.radiusXl)),
              border: Border.all(color: c.colorBorderSubtle, width: PxDsTokens.borderWidthHairline),
              boxShadow: shadow,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(PxDsTokens.radiusXl)),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                head,
                content,
                if (foot != null) foot,
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
