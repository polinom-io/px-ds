import 'package:flutter/material.dart';

import '../icons/icons.g.dart';
import '../tokens/tokens.g.dart';
import 'field_message.dart';
import 'icon.dart';
import 'selection_row.dart';
import 'theme_access.dart';

/// Checkbox (INP-05): a box with its label, for choices that are saved with a form.
///
/// * [value] `true` is checked, `false` unchecked, `null` indeterminate (only with [tristate]),
///   e.g. a "Select all" whose items are partly selected. Tapping an indeterminate box checks it.
/// * Checked: fill color-action-primary-bg with a check in color-action-primary-fg. Indeterminate:
///   the same fill with a minus.
/// * [error] adds the x-circle icon and message below and a 2px danger outline; the message is
///   read with the label.
/// * For several related options, put them under one heading (a fieldset), or use
///   [PxDsRadioGroup] when only one may be chosen.
class PxDsCheckbox extends StatelessWidget {
  const PxDsCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.tristate = false,
    this.description,
    this.error,
  }) : assert(tristate || value != null, 'value can be null only when tristate is true');

  final String label;
  final String? description;
  final bool? value;
  final bool tristate;

  /// Null disables the checkbox.
  final ValueChanged<bool?>? onChanged;

  /// Message to show; validation is the caller's. Non-null marks the checkbox invalid.
  final String? error;

  @override
  Widget build(BuildContext context) {
    final c = PxDsThemeData.of(context).colors;
    final on = value != false;
    final hasError = error != null;
    const box = PxDsTokens.sizeIconMd;
    final row = PxDsSelectionRow(
      label: label,
      description: description,
      checked: value == true,
      mixed: value == null,
      semanticsSuffix: error,
      onTap: onChanged == null ? null : () => onChanged!(value != true),
      control: (states) => PxDsFocusFrame(
        focused: states.contains(WidgetState.focused),
        radius: PxDsTokens.radiusSm,
        child: Container(
          width: box,
          height: box,
          decoration: BoxDecoration(
            color: on ? c.colorActionPrimaryBg : c.colorSurfaceDefault,
            borderRadius: const BorderRadius.all(Radius.circular(PxDsTokens.radiusSm)),
            border: hasError
                ? Border.all(color: c.colorFeedbackDangerFg, width: PxDsTokens.borderWidthThick)
                : Border.all(color: on ? c.colorActionPrimaryBg : c.colorBorderControl, width: PxDsTokens.borderWidthHairline),
          ),
          foregroundDecoration: BoxDecoration(
            color: pxDsStateLayer(states, c.colorTextDefault),
            borderRadius: const BorderRadius.all(Radius.circular(PxDsTokens.radiusSm)),
          ),
          alignment: Alignment.center,
          child: on ? PxDsIcon(value == null ? PxDsIcons.minus : PxDsIcons.check, size: PxDsTokens.sizeIconSm, color: c.colorActionPrimaryFg) : null,
        ),
      ),
    );
    if (!hasError) return row;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      row,
      // In line with the label: past the box, its focus frame and the gap.
      Padding(padding: const EdgeInsets.only(left: box + 4 * PxDsTokens.borderWidthFocus + PxDsTokens.space3), child: PxDsFieldMessage(error: error)),
    ]);
  }
}
