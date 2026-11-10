import 'package:flutter_test/flutter_test.dart';
import 'package:px_ds/px_ds.dart';

void main() {
  test('29 front and 28 back regions with unique stored ids', () {
    expect(PxDsBodyRegion.onFace(PxDsBodyFace.front), hasLength(29));
    expect(PxDsBodyRegion.onFace(PxDsBodyFace.back), hasLength(28));
    final ids = PxDsBodyRegion.values.map((r) => r.id).toSet();
    expect(ids, hasLength(PxDsBodyRegion.values.length));
    for (final r in PxDsBodyRegion.values) {
      expect(r.id, endsWith('-${r.face.name}'));
      expect(PxDsBodyRegion.fromId(r.id), r);
    }
    expect(PxDsBodyRegion.fromId('knee-left-front'), PxDsBodyRegion.kneeLeftFront);
    expect(PxDsBodyRegion.fromId('no-such-region'), isNull);
  });

  test("sides are the person's own: the front's right side is drawn on the viewer's left", () {
    for (final r in PxDsBodyRegion.values) {
      final viewerLeft = r.labelPoint.dx < pxDsBodyViewBox.center.dx;
      if (r.side == PxDsBodySide.none) {
        expect(r.labelPoint.dx, closeTo(pxDsBodyViewBox.center.dx, 0.5), reason: r.id);
      } else if (r.face == PxDsBodyFace.front) {
        expect(viewerLeft, r.side == PxDsBodySide.right, reason: r.id);
      } else {
        expect(viewerLeft, r.side == PxDsBodySide.left, reason: r.id);
      }
    }
  });

  test('every outline sits in the view box, is at least 24 x 24 and holds its label point', () {
    for (final r in PxDsBodyRegion.values) {
      final b = r.path.getBounds();
      expect(pxDsBodyViewBox.inflate(0.01).contains(b.topLeft) && pxDsBodyViewBox.inflate(0.01).contains(b.bottomRight), isTrue, reason: r.id);
      expect(b.width, greaterThanOrEqualTo(23.9), reason: '${r.id} width');
      expect(b.height, greaterThanOrEqualTo(23.9), reason: '${r.id} height');
      expect(r.path.contains(r.labelPoint), isTrue, reason: r.id);
    }
  });
}
