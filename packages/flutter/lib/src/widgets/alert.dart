import 'package:flutter/widgets.dart';

import '../icons/icons.g.dart';
import '../tokens/tokens.g.dart';
import 'icon.dart';
import 'theme_access.dart';

enum PxDsAlertTone { info, success, warning, danger }

/// Alert (FBK-01): an inline status message. Every tone has its icon and a title, so colour never
/// carries the status alone. Warning and danger are a live region, so screen readers announce them
/// when they appear.
class PxDsAlert extends StatelessWidget {
  const PxDsAlert({super.key, this.tone = PxDsAlertTone.info, this.title, this.body});

  final PxDsAlertTone tone;

  /// What happened. Defaults to the tone's name.
  final String? title;

  /// What to do next.
  final String? body;

  @override
  Widget build(BuildContext context) {
    final ds = PxDsThemeData.of(context);
    final c = ds.colors;
    final t = ds.type;
    final (Color fg, Color bg, PxDsIconData icon, String name) = switch (tone) {
      PxDsAlertTone.info => (c.colorFeedbackInfoFg, c.colorFeedbackInfoBg, PxDsIcons.info, 'Info'),
      PxDsAlertTone.success => (c.colorFeedbackSuccessFg, c.colorFeedbackSuccessBg, PxDsIcons.checkCircle, 'Success'),
      PxDsAlertTone.warning => (c.colorFeedbackWarningFg, c.colorFeedbackWarningBg, PxDsIcons.warning, 'Warning'),
      PxDsAlertTone.danger => (c.colorFeedbackDangerFg, c.colorFeedbackDangerBg, PxDsIcons.xCircle, 'Error'),
    };
    final urgent = tone == PxDsAlertTone.warning || tone == PxDsAlertTone.danger;
    return Semantics(
      container: true,
      liveRegion: urgent,
      child: DecoratedBox(
        decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.all(Radius.circular(PxDsTokens.radiusMd))),
        child: Padding(
          padding: const EdgeInsets.all(PxDsTokens.space4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PxDsIcon(icon, size: PxDsTokens.sizeIconLg, color: fg),
              const SizedBox(width: PxDsTokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title ?? name, style: t.textTitleSm.copyWith(color: fg)),
                    if (body != null) ...[
                      const SizedBox(height: PxDsTokens.space1),
                      Text(body!, style: t.textBodySm.copyWith(color: c.colorTextDefault)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
