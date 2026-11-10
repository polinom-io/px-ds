import 'package:flutter/widgets.dart';

import 'layout_tokens.dart';

/// Stack (LAY-02): children in a line with a token gap between them.
///
/// Vertical by default. With [wrap], children flow onto new lines when they run out of room, with
/// the same gap between lines. Reading order is child order, so put them in the order people
/// should hear them.
class PxDsStack extends StatelessWidget {
  const PxDsStack({
    super.key,
    this.axis = Axis.vertical,
    this.gap = PxDsSpace.s4,
    this.align = CrossAxisAlignment.start,
    this.justify = MainAxisAlignment.start,
    this.wrap = false,
    required this.children,
  });

  const PxDsStack.horizontal({
    super.key,
    this.gap = PxDsSpace.s4,
    this.align = CrossAxisAlignment.center,
    this.justify = MainAxisAlignment.start,
    this.wrap = false,
    required this.children,
  }) : axis = Axis.horizontal;

  final Axis axis;
  final PxDsSpace gap;

  /// Placement across the stack's direction. Defaults to start (vertical) or centre (horizontal).
  final CrossAxisAlignment align;

  /// Placement along the stack's direction.
  final MainAxisAlignment justify;
  final bool wrap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (wrap) {
      return Wrap(
        direction: axis,
        spacing: gap.value,
        runSpacing: gap.value,
        crossAxisAlignment: switch (align) {
          CrossAxisAlignment.start => WrapCrossAlignment.start,
          CrossAxisAlignment.end => WrapCrossAlignment.end,
          _ => WrapCrossAlignment.center,
        },
        alignment: switch (justify) {
          MainAxisAlignment.end => WrapAlignment.end,
          MainAxisAlignment.center => WrapAlignment.center,
          MainAxisAlignment.spaceBetween => WrapAlignment.spaceBetween,
          MainAxisAlignment.spaceAround => WrapAlignment.spaceAround,
          MainAxisAlignment.spaceEvenly => WrapAlignment.spaceEvenly,
          _ => WrapAlignment.start,
        },
        children: children,
      );
    }
    final spaced = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0 && gap != PxDsSpace.s0) {
        spaced.add(axis == Axis.vertical ? SizedBox(height: gap.value) : SizedBox(width: gap.value));
      }
      spaced.add(children[i]);
    }
    return Flex(
      direction: axis,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: align,
      mainAxisAlignment: justify,
      children: spaced,
    );
  }
}
