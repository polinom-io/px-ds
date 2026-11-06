/// Polinom.io Design System for Flutter.
///
/// Add the theme extensions to your [ThemeData]:
///
/// ```dart
/// ThemeData(extensions: PxDsTheme.extensions(PxDsBrand.treatmint, Brightness.light))
/// ```
///
/// then use the widgets (`PxDsButton`, `PxDsTextField`, `PxDsCard`, `PxDsAlert`, `PxDsIcon`) or
/// read the tokens with `Theme.of(context).extension<PxDsColors>()!`.
library;

export 'src/icons/icons.g.dart';
export 'src/tokens/tokens.g.dart';
export 'src/widgets/alert.dart';
export 'src/widgets/button.dart';
export 'src/widgets/card.dart';
export 'src/widgets/icon.dart';
export 'src/widgets/text_field.dart';
export 'src/widgets/theme_access.dart' show PxDsTone, PxDsThemeData;
