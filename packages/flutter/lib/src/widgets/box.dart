import 'package:flutter/widgets.dart';

import '../tokens/tokens.g.dart';
import 'layout_tokens.dart';
import 'theme_access.dart';

/// Box (LAY-01): the token-driven building block for spacing, a surface, a border and a radius.
///
/// Every value is a token step, never a raw number. A box has no semantics of its own. Text on a
/// surface must use `color-text-default` or `color-text-muted`, the pairs that are checked on every
/// surface.
class PxDsBox extends StatelessWidget {
  const PxDsBox({
    super.key,
    this.padding = PxDsSpace.s0,
    this.paddingX,
    this.paddingY,
    this.surface,
    this.bordered = false,
    this.radius = PxDsRadius.none,
    this.child,
  });

  /// Space on all sides. [paddingX] and [paddingY] override it per axis.
  final PxDsSpace padding;
  final PxDsSpace? paddingX;
  final PxDsSpace? paddingY;

  /// Fill; null leaves the box transparent.
  final PxDsSurface? surface;

  /// A hairline in `color-border-subtle`. Decoration only: it never carries meaning.
  final bool bordered;
  final PxDsRadius radius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final c = PxDsThemeData.of(context).colors;
    final fill = switch (surface) {
      PxDsSurface.page => c.colorSurfacePage,
      PxDsSurface.sunken => c.colorSurfaceSunken,
      PxDsSurface.base => c.colorSurfaceDefault,
      PxDsSurface.raised => c.colorSurfaceRaised,
      null => null,
    };
    final shape = BorderRadius.all(Radius.circular(radius.value));
    final inner = Padding(
      padding: EdgeInsets.symmetric(horizontal: (paddingX ?? padding).value, vertical: (paddingY ?? padding).value),
      child: child,
    );
    if (fill == null && !bordered && radius == PxDsRadius.none) return inner;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: shape,
        border: bordered ? Border.all(color: c.colorBorderSubtle, width: PxDsTokens.borderWidthHairline) : null,
      ),
      child: inner,
    );
  }
}
