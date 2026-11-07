import 'package:flutter/material.dart';

import '../tokens/tokens.g.dart';
import 'selection_row.dart';
import 'theme_access.dart';

/// Switch (INP-07): turns a setting on or off at once, with no Save button.
///
/// * The label sits to the right of the track; the whole row is the hit area.
/// * Off: track color-surface-sunken outlined in color-border-control, thumb color-border-control.
///   On: track color-action-primary-bg, thumb color-action-primary-fg, moved to the end.
/// * Screen readers hear the label and "on" or "off". Space and Enter toggle it.
/// * If the change needs confirming, use [PxDsCheckbox] inside a form instead.
class PxDsSwitch extends StatelessWidget {
  const PxDsSwitch({super.key, required this.label, required this.value, required this.onChanged, this.description});

  final String label;
  final String? description;
  final bool value;

  /// Null disables the switch.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = PxDsThemeData.of(context).colors;
    final duration = (MediaQuery.maybeDisableAnimationsOf(context) ?? false) ? Duration.zero : PxDsTokens.motionDurationFast;
    // Track 44 x 24, thumb 16, as on the web package.
    const trackW = PxDsTokens.sizeTouchMin, trackH = PxDsTokens.sizeIconLg, thumb = PxDsTokens.sizeIconSm;
    const inset = (trackH - thumb) / 2 - PxDsTokens.borderWidthHairline;
    return PxDsSelectionRow(
      label: label,
      description: description,
      toggled: value,
      onTap: onChanged == null ? null : () => onChanged!(!value),
      control: (states) => PxDsFocusFrame(
        focused: states.contains(WidgetState.focused),
        radius: trackH / 2,
        child: AnimatedContainer(
          duration: duration,
          curve: PxDsTokens.motionEasingEnter,
          width: trackW,
          height: trackH,
          decoration: BoxDecoration(
            color: value ? c.colorActionPrimaryBg : c.colorSurfaceSunken,
            borderRadius: const BorderRadius.all(Radius.circular(PxDsTokens.radiusFull)),
            border: Border.all(color: value ? c.colorActionPrimaryBg : c.colorBorderControl, width: PxDsTokens.borderWidthHairline),
          ),
          foregroundDecoration: BoxDecoration(
            color: pxDsStateLayer(states, c.colorTextDefault),
            borderRadius: const BorderRadius.all(Radius.circular(PxDsTokens.radiusFull)),
          ),
          child: AnimatedAlign(
            duration: duration,
            curve: PxDsTokens.motionEasingEnter,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: inset),
              child: Container(
                key: const Key('px-switch-thumb'),
                width: thumb,
                height: thumb,
                decoration: BoxDecoration(color: value ? c.colorActionPrimaryFg : c.colorBorderControl, shape: BoxShape.circle),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
