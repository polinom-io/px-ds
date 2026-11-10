import 'package:flutter/widgets.dart';

import '../tokens/tokens.g.dart';
import 'layout_tokens.dart';

/// Page widths for [PxDsContainer]: `sm` 640 (bp-sm), `md` 1024 (bp-lg), `lg` 1200 (container-max).
enum PxDsContainerSize {
  sm(PxDsTokens.bpSm),
  md(PxDsTokens.bpLg),
  lg(PxDsTokens.containerMax),
  full(double.infinity);

  const PxDsContainerSize(this.maxWidth);
  final double maxWidth;
}

/// Container (LAY-04): centres content at a maximum page width, with side padding that grows with
/// the width (space-4 below bp-md, space-6 from there). `full` has no maximum. It fills the width it
/// is given up to the maximum, so it needs a bounded width.
class PxDsContainer extends StatelessWidget {
  const PxDsContainer({super.key, this.size = PxDsContainerSize.lg, required this.child});

  final PxDsContainerSize size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final gutter = (constraints.maxWidth < PxDsTokens.bpMd ? PxDsSpace.s4 : PxDsSpace.s6).value;
      return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: size.maxWidth),
          child: SizedBox(width: double.infinity, child: Padding(padding: EdgeInsets.symmetric(horizontal: gutter), child: child)),
        ),
      );
    });
  }
}
