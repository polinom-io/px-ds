import 'package:flutter/widgets.dart';

import '../tokens/tokens.g.dart';
import 'layout_tokens.dart';
import 'theme_access.dart';

/// Divider (LAY-05): a hairline in `color-border-subtle` that separates content.
///
/// Horizontal fills the width it is given; vertical fills the height it is given (a bounded one:
/// in a sized box, or a row with stretched alignment). The line is decoration and is left out of semantics. A
/// [label] ("or") is read as text, set in label-sm muted, and only applies to horizontal dividers.
class PxDsDivider extends StatelessWidget {
  const PxDsDivider({super.key, this.axis = Axis.horizontal, this.label})
      : assert(label == null || axis == Axis.horizontal, 'Only a horizontal divider can have a label');

  final Axis axis;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final ds = PxDsThemeData.of(context);
    final line = ExcludeSemantics(child: ColoredBox(color: ds.colors.colorBorderSubtle));
    if (axis == Axis.vertical) {
      return SizedBox(width: PxDsTokens.borderWidthHairline, child: SizedBox.expand(child: line));
    }
    final rule = SizedBox(height: PxDsTokens.borderWidthHairline, child: SizedBox.expand(child: line));
    if (label == null) return rule;
    return Row(children: [
      Expanded(child: rule),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: PxDsSpace.s3.value),
        child: Text(label!, style: ds.type.textLabelSm.copyWith(color: ds.colors.colorTextMuted)),
      ),
      Expanded(child: rule),
    ]);
  }
}
