import 'package:flutter/material.dart';

import '../tokens/tokens.g.dart';
import 'theme_access.dart';

enum PxDsButtonVariant { primary, secondary, ghost, danger }

enum PxDsButtonSize { sm, md, lg }

/// Button (ACT-01). Built on Material's [TextButton] for focus, keyboard, semantics and touch
/// target; every colour, size and shape comes from the tokens.
///
/// * `primary`: the one main action per view. `secondary`: outlined. `ghost`: no fill until
///   hover or press. `danger`: destructive, behind a confirmation.
/// * Size defaults to `lg` (48, the touch default on mobile). `sm` keeps a 48 hit area.
/// * Hover and press add a state layer of the label colour (opacity-state-hover / -pressed);
///   focus draws the 2px focus ring; disabled uses opacity-disabled.
class PxDsButton extends StatelessWidget {
  const PxDsButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PxDsButtonVariant.primary,
    this.size = PxDsButtonSize.lg,
  });

  /// A verb in sentence case: "Save changes", not "OK".
  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final PxDsButtonVariant variant;
  final PxDsButtonSize size;

  @override
  Widget build(BuildContext context) {
    final ds = PxDsThemeData.of(context);
    final c = ds.colors;
    final (Color bg, Color fg) = switch (variant) {
      PxDsButtonVariant.primary => (c.colorActionPrimaryBg, c.colorActionPrimaryFg),
      PxDsButtonVariant.secondary => (c.colorActionSecondaryBg, c.colorActionSecondaryFg),
      PxDsButtonVariant.ghost => (const Color(0x00000000), c.colorActionSecondaryFg),
      PxDsButtonVariant.danger => (c.colorActionDestructiveBg, c.colorActionDestructiveFg),
    };
    final (double height, double padding, TextStyle text) = switch (size) {
      PxDsButtonSize.sm => (PxDsTokens.sizeControlSm, PxDsTokens.space3, ds.type.textLabelSm),
      PxDsButtonSize.md => (PxDsTokens.sizeControlMd, PxDsTokens.space4, ds.type.textLabelMd),
      PxDsButtonSize.lg => (PxDsTokens.sizeControlLg, PxDsTokens.space5, ds.type.textLabelMd),
    };
    final style = ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(bg),
      foregroundColor: WidgetStatePropertyAll(fg),
      overlayColor: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.pressed)) return fg.withValues(alpha: PxDsTokens.opacityStatePressed);
        if (s.contains(WidgetState.hovered)) return fg.withValues(alpha: PxDsTokens.opacityStateHover);
        return null;
      }),
      side: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.focused)) return BorderSide(color: c.colorFocusRing, width: PxDsTokens.borderWidthFocus);
        if (variant == PxDsButtonVariant.secondary) {
          return BorderSide(color: s.contains(WidgetState.hovered) ? c.colorBorderStrong : c.colorBorderControl, width: PxDsTokens.borderWidthHairline);
        }
        return BorderSide.none;
      }),
      shape: const WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(PxDsTokens.radiusMd)))),
      minimumSize: WidgetStatePropertyAll(Size(height, height)),
      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: padding)),
      textStyle: WidgetStatePropertyAll(text),
      elevation: const WidgetStatePropertyAll(0),
      tapTargetSize: MaterialTapTargetSize.padded,
      animationDuration: PxDsTokens.motionDurationFast,
    );
    final button = TextButton(onPressed: onPressed, style: style, child: Text(label));
    return onPressed == null ? Opacity(opacity: PxDsTokens.opacityDisabled, child: button) : button;
  }
}
