import '../tokens/tokens.g.dart';

/// A step on the spacing scale (FND-03). Layout widgets take these, never raw numbers.
enum PxDsSpace {
  s0(PxDsTokens.space0),
  s1(PxDsTokens.space1),
  s2(PxDsTokens.space2),
  s3(PxDsTokens.space3),
  s4(PxDsTokens.space4),
  s5(PxDsTokens.space5),
  s6(PxDsTokens.space6),
  s8(PxDsTokens.space8),
  s10(PxDsTokens.space10),
  s12(PxDsTokens.space12),
  s16(PxDsTokens.space16),
  s24(PxDsTokens.space24);

  const PxDsSpace(this.value);

  /// The token value in logical pixels.
  final double value;
}

/// A step on the radius scale (FND-05).
enum PxDsRadius {
  none(PxDsTokens.radiusNone),
  sm(PxDsTokens.radiusSm),
  md(PxDsTokens.radiusMd),
  lg(PxDsTokens.radiusLg),
  xl(PxDsTokens.radiusXl),
  full(PxDsTokens.radiusFull);

  const PxDsRadius(this.value);
  final double value;
}

/// A surface a [PxDsBox] can sit on: `color-surface-page`, `-sunken`, `-default` (base) or `-raised`.
enum PxDsSurface { page, sunken, base, raised }
