import 'package:flutter/widgets.dart';

import '../icons/icons.g.dart';
import '../tokens/tokens.g.dart';
import 'icon.dart';
import 'theme_access.dart';

/// Helper or error text under a control (INP-15). Internal.
///
/// An error replaces the helper and always carries the x-circle icon, so it never relies on
/// colour alone. Excluded from semantics: the control reads the same words as part of its label.
class PxDsFieldMessage extends StatelessWidget {
  const PxDsFieldMessage({super.key, this.helper, this.error});
  final String? helper;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final ds = PxDsThemeData.of(context);
    final c = ds.colors;
    if (error == null && helper == null) return const SizedBox.shrink();
    final style = ds.type.textCaptionSm.copyWith(color: error != null ? c.colorFeedbackDangerFg : c.colorTextMuted);
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.only(top: PxDsTokens.space1),
        child: error != null
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1, right: PxDsTokens.space1),
                  child: PxDsIcon(PxDsIcons.xCircle, size: PxDsTokens.sizeIconSm, color: c.colorFeedbackDangerFg),
                ),
                Expanded(child: Text(error!, style: style)),
              ])
            : Text(helper!, style: style),
      ),
    );
  }
}
