/// Polinom.io Design System for Flutter.
///
/// Add the theme extensions to your [ThemeData]:
///
/// ```dart
/// ThemeData(extensions: PxDsTheme.extensions(PxDsBrand.treatmint, Brightness.light))
/// ```
///
/// then use the widgets (`PxDsButton`, `PxDsTextField`, `PxDsCheckbox`, `PxDsRadioGroup`, `PxDsSwitch`,
/// `showPxDsDialog`, `PxDsCard`, `PxDsAlert`, `PxDsIcon`, and the layout primitives `PxDsBox`, `PxDsStack`,
/// `PxDsGrid`, `PxDsContainer`, `PxDsDivider`, `PxDsVisuallyHidden`) or
/// read the tokens with `Theme.of(context).extension<PxDsColors>()!`.
library;

export 'src/body/body_regions.g.dart';
export 'src/icons/icons.g.dart';
export 'src/tokens/tokens.g.dart';
export 'src/widgets/alert.dart';
export 'src/widgets/box.dart';
export 'src/widgets/button.dart';
export 'src/widgets/card.dart';
export 'src/widgets/checkbox.dart';
export 'src/widgets/container.dart';
export 'src/widgets/dialog.dart';
export 'src/widgets/divider.dart';
export 'src/widgets/grid.dart';
export 'src/widgets/icon.dart';
export 'src/widgets/layout_tokens.dart';
export 'src/widgets/radio_group.dart';
export 'src/widgets/stack.dart';
export 'src/widgets/switch.dart';
export 'src/widgets/text_field.dart';
export 'src/widgets/visually_hidden.dart';
export 'src/widgets/theme_access.dart' show PxDsTone, PxDsThemeData;
