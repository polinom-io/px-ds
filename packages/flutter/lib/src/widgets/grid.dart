import 'package:flutter/widgets.dart';

import '../tokens/tokens.g.dart';

/// One cell of a [PxDsGrid], with how many columns it spans at each width.
///
/// A span is clamped to the columns available. [spanMd] defaults to [span] and [spanLg] to
/// [spanMd]. With no span at all a cell takes the full row.
class PxDsGridItem extends StatelessWidget {
  const PxDsGridItem({super.key, this.span, this.spanMd, this.spanLg, required this.child});

  /// Columns on the 4-column grid (narrower than bp-md).
  final int? span;

  /// Columns on the 8-column grid (bp-md up to bp-lg).
  final int? spanMd;

  /// Columns on the 12-column grid (bp-lg and wider).
  final int? spanLg;
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// Grid (LAY-03): 4 columns below bp-md, 8 up to bp-lg, 12 from bp-lg, with a gutter of space-4
/// (space-6 from bp-lg). The width it measures is its own, not the screen's, so a grid inside a
/// narrower container follows the container.
///
/// Cells flow left to right and start a new row when the next one does not fit. Reading order is
/// cell order.
class PxDsGrid extends StatelessWidget {
  const PxDsGrid({super.key, required this.children});

  final List<PxDsGridItem> children;

  /// Columns for a grid [width] wide.
  static int columnsFor(double width) => width >= PxDsTokens.bpLg ? 12 : (width >= PxDsTokens.bpMd ? 8 : 4);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final columns = columnsFor(width);
      final gutter = width >= PxDsTokens.bpLg ? PxDsTokens.space6 : PxDsTokens.space4;
      final column = (width - gutter * (columns - 1)) / columns;

      int spanOf(PxDsGridItem item) {
        final base = item.span ?? columns;
        final md = item.spanMd ?? base;
        final lg = item.spanLg ?? md;
        final wanted = columns == 12 ? lg : (columns == 8 ? md : base);
        return wanted.clamp(1, columns);
      }

      final rows = <List<(PxDsGridItem, int)>>[[]];
      var used = 0;
      for (final item in children) {
        final span = spanOf(item);
        if (used + span > columns) {
          rows.add([]);
          used = 0;
        }
        rows.last.add((item, span));
        used += span;
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var r = 0; r < rows.length; r++) ...[
            if (r > 0) SizedBox(height: gutter),
            if (rows[r].isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < rows[r].length; i++) ...[
                    if (i > 0) SizedBox(width: gutter),
                    SizedBox(width: column * rows[r][i].$2 + gutter * (rows[r][i].$2 - 1), child: rows[r][i].$1),
                  ],
                ],
              ),
          ],
        ],
      );
    });
  }
}
