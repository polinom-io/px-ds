import 'package:flutter/widgets.dart';

import '../tokens/tokens.g.dart';
import 'theme_access.dart';

/// Card (DSP-01): content on color-surface-default with a 3px accent top edge in [tone].
///
/// The edge is decoration that groups related cards; it never encodes status. No shadow at rest.
class PxDsCard extends StatelessWidget {
  const PxDsCard({super.key, this.tone = PxDsTone.primary, this.exponent, this.title, this.body, this.child});

  final PxDsTone tone;

  /// Small code-font chip above the title, e.g. "x³" or "// solved for".
  final String? exponent;
  final String? title;

  /// Plain text body, set in body-md muted. Use [child] for anything richer.
  final String? body;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final ds = PxDsThemeData.of(context);
    final c = ds.colors;
    final t = ds.type;
    final accent = ds.tone(tone);
    const radius = BorderRadius.all(Radius.circular(PxDsTokens.radiusLg));
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.colorSurfaceDefault,
        borderRadius: radius,
        border: Border.all(color: c.colorBorderSubtle, width: PxDsTokens.borderWidthHairline),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 3, color: accent),
            Padding(
              padding: const EdgeInsets.all(PxDsTokens.space6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (exponent != null) ...[
                    Text(exponent!, style: t.textCodeMd.copyWith(color: accent)),
                    const SizedBox(height: PxDsTokens.space2),
                  ],
                  if (title != null) ...[
                    Semantics(header: true, child: Text(title!, style: t.textTitleMd.copyWith(color: c.colorTextDefault))),
                    const SizedBox(height: PxDsTokens.space2),
                  ],
                  if (body != null) Text(body!, style: t.textBodyMd.copyWith(color: c.colorTextMuted)),
                  if (child != null) DefaultTextStyle.merge(style: t.textBodyMd.copyWith(color: c.colorTextDefault), child: child!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
