import 'package:flutter/widgets.dart';

import '../icons/icons.g.dart';

/// Draws a Phosphor icon from [PxDsIcons]. Decorative by default (excluded from semantics); pass
/// [semanticLabel] when the icon is the only thing that says what something does.
class PxDsIcon extends StatelessWidget {
  const PxDsIcon(this.icon, {super.key, this.size, this.color, this.semanticLabel});

  final PxDsIconData icon;

  /// Logical pixels. Defaults to the ambient [IconTheme] size, else 24 (size-icon-lg).
  final double? size;

  /// Defaults to the ambient [IconTheme] colour, else the text colour.
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final s = size ?? iconTheme.size ?? 24;
    final c = color ?? iconTheme.color ?? DefaultTextStyle.of(context).style.color ?? const Color(0xFF000000);
    final painted = SizedBox.square(dimension: s, child: CustomPaint(painter: _IconPainter(icon, c)));
    return semanticLabel == null ? ExcludeSemantics(child: painted) : Semantics(label: semanticLabel, image: true, child: ExcludeSemantics(child: painted));
  }
}

class _IconPainter extends CustomPainter {
  _IconPainter(this.icon, this.color);
  final PxDsIconData icon;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 256, size.height / 256);
    canvas.drawPath(icon.path, Paint()..color = color..isAntiAlias = true);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_IconPainter old) => old.icon != icon || old.color != color;
}
