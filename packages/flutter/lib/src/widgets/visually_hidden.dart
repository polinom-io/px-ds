import 'package:flutter/widgets.dart';

/// Visually hidden (LAY-08): text that screen readers read and nobody sees, for a cue that sighted
/// users get from layout, such as "Required" next to a star or a heading for a group of rows.
///
/// It takes no room and paints nothing. Use it to add words, never to hide something that is
/// shown: a hidden control still has to be reachable and make sense.
class PxDsVisuallyHidden extends StatelessWidget {
  const PxDsVisuallyHidden(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: text,
      textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
      container: true,
      child: const SizedBox(width: 1, height: 1),
    );
  }
}
