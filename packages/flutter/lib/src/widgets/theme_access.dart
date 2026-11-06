import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Theme;

import '../tokens/tokens.g.dart';

/// Accent tone for Card (and later Badge, Avatar, Progress). Maps to color-accent-*.
enum PxDsTone { primary, secondary, tertiary, quaternary }

/// The design-system theme extensions for [context], with a clear error when they are missing.
@immutable
class PxDsThemeData {
  const PxDsThemeData(this.colors, this.type);
  final PxDsColors colors;
  final PxDsTypography type;

  static PxDsThemeData of(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<PxDsColors>();
    final type = theme.extension<PxDsTypography>();
    if (colors == null || type == null) {
      throw FlutterError(
        'px_ds widgets need the design-system theme extensions.\n'
        'Add them to your ThemeData: ThemeData(extensions: PxDsTheme.extensions(brand, brightness)).',
      );
    }
    return PxDsThemeData(colors, type);
  }

  Color tone(PxDsTone tone) => switch (tone) {
        PxDsTone.primary => colors.colorAccentPrimary,
        PxDsTone.secondary => colors.colorAccentSecondary,
        PxDsTone.tertiary => colors.colorAccentTertiary,
        PxDsTone.quaternary => colors.colorAccentQuaternary,
      };
}
