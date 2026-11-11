import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../body/body_regions.g.dart';
import '../tokens/tokens.g.dart';
import 'button.dart';
import 'checkbox.dart';
import 'field_message.dart';
import 'theme_access.dart';

/// How the two faces of the figure are laid out.
enum PxDsBodyLayout {
  /// One face at a time, with a face toggle. For phones.
  switcher,

  /// Front and back next to each other, no toggle.
  sideBySide,
}

/// Figure height: 160, 320 or 440 dp (see the spec's Sizes table).
enum PxDsBodySize {
  small(160),
  medium(320),
  large(440);

  const PxDsBodySize(this.height);
  final double height;
}

/// The words around the figure, in one language. Region names come from the generated region
/// list (`englishLabel`, `spanishLabel`), so a screen never writes them.
class PxDsBodyStrings {
  const PxDsBodyStrings({
    required this.spanish,
    required this.front,
    required this.back,
    required this.frontView,
    required this.backView,
    required this.noneSelected,
    required this.noneRecorded,
    required this.selectedPrefix,
    required this.recordedPrefix,
    required this.andMore,
    required this.chooseFromList,
    required this.showFigure,
    required this.regionSelected,
    required this.regionNotSelected,
    required this.groupHeadNeck,
    required this.groupArms,
    required this.groupTorso,
    required this.groupBack,
    required this.groupLegs,
  });

  /// English.
  static const en = PxDsBodyStrings(
    spanish: false,
    front: 'Front',
    back: 'Back',
    frontView: 'Front view',
    backView: 'Back view',
    noneSelected: 'No areas selected',
    noneRecorded: 'No areas recorded',
    selectedPrefix: 'Selected: ',
    recordedPrefix: 'Recorded: ',
    andMore: _andMoreEn,
    chooseFromList: 'Choose from a list',
    showFigure: 'Show the figure',
    regionSelected: 'selected',
    regionNotSelected: 'not selected',
    groupHeadNeck: 'Head and neck',
    groupArms: 'Arms and hands',
    groupTorso: 'Torso',
    groupBack: 'Back',
    groupLegs: 'Legs and feet',
  );

  /// Spanish (Chile).
  static const esCl = PxDsBodyStrings(
    spanish: true,
    front: 'Frente',
    back: 'Espalda',
    frontView: 'Vista frontal',
    backView: 'Vista posterior',
    noneSelected: 'Ninguna zona seleccionada',
    noneRecorded: 'Ninguna zona registrada',
    selectedPrefix: 'Seleccionadas: ',
    recordedPrefix: 'Registradas: ',
    andMore: _andMoreEs,
    chooseFromList: 'Elegir de una lista',
    showFigure: 'Mostrar la figura',
    regionSelected: 'seleccionada',
    regionNotSelected: 'no seleccionada',
    groupHeadNeck: 'Cabeza y cuello',
    groupArms: 'Brazos y manos',
    groupTorso: 'Torso',
    groupBack: 'Espalda',
    groupLegs: 'Piernas y pies',
  );

  static String _andMoreEn(int n) => 'and $n more';
  static String _andMoreEs(int n) => 'y $n más';

  /// Picks the Spanish labels when true.
  final bool spanish;
  final String front;
  final String back;
  final String frontView;
  final String backView;
  final String noneSelected;
  final String noneRecorded;
  final String selectedPrefix;
  final String recordedPrefix;

  /// "and 3 more".
  final String Function(int) andMore;
  final String chooseFromList;
  final String showFigure;
  final String regionSelected;
  final String regionNotSelected;
  final String groupHeadNeck;
  final String groupArms;
  final String groupTorso;
  final String groupBack;
  final String groupLegs;

  /// The label of [region] in this language.
  String region(PxDsBodyRegion region) => spanish ? region.spanishLabel : region.englishLabel;
}

/// Body outline (INP-19): a front and back figure split into named regions. People tap regions to
/// say where it hurts; display-only screens show where something was recorded.
///
/// * **Select** when [onChanged] is set, **display-only** when it is null. Controlled: the screen
///   passes [selected] and gets the new set back. Records store `region.id`, never the index.
/// * Every region is its own control for screen readers, in head-to-foot order, with the side the
///   person's own ("Left knee, front"); the figure itself has no description. Keyboard: Tab moves
///   through the regions in that order, Space or Enter toggles.
/// * A selected region has a thicker outline as well as a fill, and the summary under the figure
///   names every selected region in words. [labels] show short text on regions (display-only).
/// * "Choose from a list" shows the same regions as checkboxes, grouped by area, bound to the same
///   selection. It is always available when selecting, for anyone who can't use the figure.
/// * Selecting needs [PxDsBodySize.large]: below 440 dp the hands and feet get too small to tap.
///
/// Not yet: the selected fill appears instantly (no fade), label badges don't move apart with a
/// leader line when they collide, and the large figure is a fixed 440 tall rather than filling
/// the height it is given.
class PxDsBodyOutline extends StatefulWidget {
  const PxDsBodyOutline({
    super.key,
    required this.label,
    this.selected = const {},
    this.onChanged,
    this.multiple = true,
    this.face = PxDsBodyFace.front,
    this.onFaceChanged,
    this.layout = PxDsBodyLayout.switcher,
    this.size,
    this.labels = const {},
    this.labelSemantics = const {},
    this.disabledRegions = const {},
    this.enabled = true,
    this.error,
    this.helper,
    this.strings = PxDsBodyStrings.en,
  });

  /// Names the whole control for screen readers, e.g. "Where does it hurt?".
  final String label;
  final Set<PxDsBodyRegion> selected;

  /// Null makes the figure display-only.
  final ValueChanged<Set<PxDsBodyRegion>>? onChanged;

  /// False for single choice ("where is it worst?").
  final bool multiple;

  /// The face shown (switcher layout). Without [onFaceChanged] the figure still switches by
  /// itself; with it, the screen can keep and restore the face.
  final PxDsBodyFace face;
  final ValueChanged<PxDsBodyFace>? onFaceChanged;
  final PxDsBodyLayout layout;

  /// Defaults to large when selecting and medium otherwise.
  final PxDsBodySize? size;

  /// Short text on a region (at most 5 characters, e.g. "7/10"); medium and large only.
  final Map<PxDsBodyRegion, String> labels;

  /// What a label sounds like, e.g. "7 out of 10" for "7/10". Defaults to the label.
  final Map<PxDsBodyRegion, String> labelSemantics;

  /// Regions the screen excludes: drawn flat, not focusable, not selectable.
  final Set<PxDsBodyRegion> disabledRegions;
  final bool enabled;

  /// Message to show; validation is the caller's. Non-null marks the control invalid.
  final String? error;
  final String? helper;
  final PxDsBodyStrings strings;

  @override
  State<PxDsBodyOutline> createState() => _PxDsBodyOutlineState();
}

class _PxDsBodyOutlineState extends State<PxDsBodyOutline> {
  late PxDsBodyFace _face = widget.face;
  var _list = false;

  bool get _selecting => widget.onChanged != null;
  PxDsBodySize get _size => widget.size ?? (_selecting ? PxDsBodySize.large : PxDsBodySize.medium);

  @override
  void didUpdateWidget(PxDsBodyOutline old) {
    super.didUpdateWidget(old);
    if (old.face != widget.face) _face = widget.face;
    if (!_selecting) _list = false;
  }

  void _setFace(PxDsBodyFace f) {
    if (f == _face) return;
    setState(() => _face = f);
    widget.onFaceChanged?.call(f);
    SemanticsService.sendAnnouncement(View.of(context), f == PxDsBodyFace.front ? widget.strings.frontView : widget.strings.backView, Directionality.of(context));
  }

  void _toggle(PxDsBodyRegion r) {
    final on = widget.onChanged;
    if (on == null || !widget.enabled || widget.disabledRegions.contains(r)) return;
    final now = Set<PxDsBodyRegion>.of(widget.selected);
    final adding = !now.contains(r);
    if (widget.multiple) {
      adding ? now.add(r) : now.remove(r);
    } else {
      now
        ..clear()
        ..add(r);
    }
    on(now);
    SemanticsService.sendAnnouncement(
      View.of(context),
      '${widget.strings.region(r)}, ${now.contains(r) ? widget.strings.regionSelected : widget.strings.regionNotSelected}',
      Directionality.of(context),
    );
  }

  /// The summary text and the full spoken form (the text shows at most 3 names when there are
  /// more than 4; screen readers always get them all).
  (String, String) _summary() {
    final s = widget.strings;
    final picked = [for (final r in PxDsBodyRegion.values) if (widget.selected.contains(r)) s.region(r)];
    if (picked.isEmpty) {
      final none = _selecting ? s.noneSelected : s.noneRecorded;
      return (none, none);
    }
    final prefix = _selecting ? s.selectedPrefix : s.recordedPrefix;
    final full = '$prefix${picked.join('; ')}';
    if (picked.length <= 4) return (full, full);
    return ('$prefix${picked.take(3).join('; ')}; ${s.andMore(picked.length - 3)}', full);
  }

  @override
  Widget build(BuildContext context) {
    assert(!_selecting || _size == PxDsBodySize.large, 'Selecting needs PxDsBodySize.large: smaller figures get hands and feet too small to tap.');
    final ds = PxDsThemeData.of(context);
    final c = ds.colors;
    final t = ds.type;
    final s = widget.strings;
    final (shown, spoken) = _summary();
    final showList = _selecting && _list;

    Widget figure(PxDsBodyFace face, int orderBase) => _BodyFigure(
          face: face,
          height: _size.height,
          orderBase: orderBase,
          selected: widget.selected,
          disabled: widget.disabledRegions,
          selecting: _selecting && widget.enabled,
          labels: _size == PxDsBodySize.small ? const {} : widget.labels,
          labelSemantics: widget.labelSemantics,
          strings: s,
          onToggle: _toggle,
        );

    final Widget body;
    if (showList) {
      body = _RegionList(
        strings: s,
        selected: widget.selected,
        disabled: widget.disabledRegions,
        enabled: widget.enabled,
        onToggle: _toggle,
      );
    } else if (widget.layout == PxDsBodyLayout.sideBySide) {
      body = FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          figure(PxDsBodyFace.front, 100),
          const SizedBox(width: PxDsTokens.space6),
          figure(PxDsBodyFace.back, 200),
        ]),
      );
    } else {
      body = Column(mainAxisSize: MainAxisSize.min, children: [
        _FaceToggle(face: _face, strings: s, onChanged: _setFace),
        const SizedBox(height: PxDsTokens.space4),
        figure(_face, 100),
      ]);
    }

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Semantics(
        container: true,
        label: widget.label,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: body),
            const SizedBox(height: PxDsTokens.space2),
            Semantics(
              container: true,
              label: spoken,
              liveRegion: true,
              child: ExcludeSemantics(child: Text(shown, textAlign: TextAlign.center, style: t.textBodySm.copyWith(color: _selecting || widget.selected.isNotEmpty ? c.colorTextDefault : c.colorTextMuted))),
            ),
            PxDsFieldMessage(helper: widget.helper, error: widget.error),
            if (_selecting) ...[
              const SizedBox(height: PxDsTokens.space2),
              Center(
                child: FocusTraversalOrder(
                  order: const NumericFocusOrder(1000),
                  child: PxDsButton(
                    label: showList ? s.showFigure : s.chooseFromList,
                    variant: PxDsButtonVariant.ghost,
                    size: PxDsButtonSize.sm,
                    onPressed: widget.enabled ? () => setState(() => _list = !_list) : null,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The front / back toggle: two buttons, the current one filled.
class _FaceToggle extends StatelessWidget {
  const _FaceToggle({required this.face, required this.strings, required this.onChanged});

  final PxDsBodyFace face;
  final PxDsBodyStrings strings;
  final ValueChanged<PxDsBodyFace> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget button(PxDsBodyFace f, String label, double order) => FocusTraversalOrder(
          order: NumericFocusOrder(order),
          child: Semantics(
            selected: face == f,
            container: true,
            child: PxDsButton(
              label: label,
              variant: face == f ? PxDsButtonVariant.primary : PxDsButtonVariant.secondary,
              size: PxDsButtonSize.md,
              onPressed: () => onChanged(f),
            ),
          ),
        );
    return Row(mainAxisSize: MainAxisSize.min, children: [
      button(PxDsBodyFace.front, strings.front, 0),
      const SizedBox(width: PxDsTokens.space2),
      button(PxDsBodyFace.back, strings.back, 1),
    ]);
  }
}

/// Region outlines, cached: the generated `path` getter builds a new Path every time.
final _paths = <PxDsBodyRegion, Path>{for (final r in PxDsBodyRegion.values) r: r.path};

/// Points along each outline, for the nearest-region lookup in the hit margin.
final _outlinePoints = <PxDsBodyRegion, List<Offset>>{
  for (final r in PxDsBodyRegion.values)
    r: [
      for (final m in _paths[r]!.computeMetrics())
        for (var d = 0.0; d < m.length; d += 2) m.getTangentForOffset(d)!.position,
    ],
};

/// The region at [p] (view-box units) on [face]: the one whose shape holds it, else the nearest
/// within [marginDp] dp ([dpPerUnit] dp per unit), else null. Disabled regions never match.
PxDsBodyRegion? _hitRegion(PxDsBodyFace face, Offset p, {required double dpPerUnit, double marginDp = 8, Set<PxDsBodyRegion> disabled = const {}}) {
  final regions = [for (final r in PxDsBodyRegion.onFace(face)) if (!disabled.contains(r)) r];
  for (final r in regions) {
    if (_paths[r]!.contains(p)) return r;
  }
  final marginUnits = marginDp / dpPerUnit;
  PxDsBodyRegion? best;
  var bestDistance = marginUnits;
  for (final r in regions) {
    for (final q in _outlinePoints[r]!) {
      final d = (q - p).distance;
      if (d <= bestDistance) {
        bestDistance = d;
        best = r;
      }
    }
  }
  return best;
}

class _BodyFigure extends StatefulWidget {
  const _BodyFigure({
    required this.face,
    required this.height,
    required this.orderBase,
    required this.selected,
    required this.disabled,
    required this.selecting,
    required this.labels,
    required this.labelSemantics,
    required this.strings,
    required this.onToggle,
  });

  final PxDsBodyFace face;
  final double height;
  final int orderBase;
  final Set<PxDsBodyRegion> selected;
  final Set<PxDsBodyRegion> disabled;
  final bool selecting;
  final Map<PxDsBodyRegion, String> labels;
  final Map<PxDsBodyRegion, String> labelSemantics;
  final PxDsBodyStrings strings;
  final ValueChanged<PxDsBodyRegion> onToggle;

  @override
  State<_BodyFigure> createState() => _BodyFigureState();
}

class _BodyFigureState extends State<_BodyFigure> {
  final _nodes = <PxDsBodyRegion, FocusNode>{};
  PxDsBodyRegion? _hover;
  PxDsBodyRegion? _pressed;

  List<PxDsBodyRegion> get _regions => PxDsBodyRegion.onFace(widget.face);

  FocusNode _node(PxDsBodyRegion r) => _nodes.putIfAbsent(r, () => FocusNode(debugLabel: 'PxDsBodyOutline ${r.id}'));

  @override
  void dispose() {
    for (final n in _nodes.values) {
      n.dispose();
    }
    super.dispose();
  }

  double get _scale => widget.height / pxDsBodyViewBox.height;

  PxDsBodyRegion? _at(Offset local) => widget.selecting
      ? _hitRegion(widget.face, local / _scale, dpPerUnit: _scale, disabled: widget.disabled)
      : null;

  @override
  Widget build(BuildContext context) {
    final ds = PxDsThemeData.of(context);
    final c = ds.colors;
    final scale = _scale;
    final size = Size(pxDsBodyViewBox.width * scale, widget.height);
    final regions = _regions;
    final focusNodes = [for (final r in regions) _node(r)];

    return SizedBox.fromSize(
      size: size,
      child: Stack(clipBehavior: Clip.none, children: [
        MouseRegion(
          onHover: (e) {
            final r = _at(e.localPosition);
            if (r != _hover) setState(() => _hover = r);
          },
          onExit: (_) => setState(() => _hover = null),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: widget.selecting ? (d) => setState(() => _pressed = _at(d.localPosition)) : null,
            onTapCancel: () => setState(() => _pressed = null),
            onTapUp: widget.selecting
                ? (d) {
                    final r = _at(d.localPosition);
                    setState(() => _pressed = null);
                    if (r != null) widget.onToggle(r);
                  }
                : null,
            child: ListenableBuilder(
              listenable: Listenable.merge(focusNodes),
              builder: (context, _) => CustomPaint(
                size: size,
                painter: _FigurePainter(
                  face: widget.face,
                  colors: c,
                  selected: widget.selected,
                  disabled: widget.disabled,
                  selecting: widget.selecting,
                  hover: _hover,
                  pressed: _pressed,
                  focused: [for (final r in regions) if (_node(r).hasFocus) r].firstOrNull,
                ),
              ),
            ),
          ),
        ),
        // One focusable, readable node per region, over its own bounds.
        for (var i = 0; i < regions.length; i++) _regionNode(regions[i], i, scale),
        for (final e in widget.labels.entries)
          if (e.key.face == widget.face) _badge(e.key, e.value, scale, ds),
      ]),
    );
  }

  Widget _regionNode(PxDsBodyRegion r, int i, double scale) {
    final bounds = _paths[r]!.getBounds();
    final name = widget.strings.region(r);
    final extra = widget.labels.containsKey(r) ? ', ${widget.labelSemantics[r] ?? widget.labels[r]}' : '';
    final on = widget.selected.contains(r);
    final off = widget.disabled.contains(r);
    final node = _node(r);
    final rect = Rect.fromLTWH(bounds.left * scale, bounds.top * scale, bounds.width * scale, bounds.height * scale);

    final Widget content;
    if (widget.selecting) {
      content = FocusTraversalOrder(
        order: NumericFocusOrder(widget.orderBase + i + 10.0),
        child: Focus(
          focusNode: node,
          canRequestFocus: !off,
          onKeyEvent: (n, e) {
            if (e is KeyDownEvent && (e.logicalKey == LogicalKeyboardKey.space || e.logicalKey == LogicalKeyboardKey.enter)) {
              widget.onToggle(r);
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: Semantics(
            button: true,
            selected: on,
            enabled: !off,
            label: name,
            focusable: !off,
            focused: node.hasFocus,
            excludeSemantics: true,
            onTap: off ? null : () => widget.onToggle(r),
            onFocus: off ? null : node.requestFocus,
            child: const SizedBox.expand(),
          ),
        ),
      );
    } else {
      content = Semantics(container: true, label: '$name$extra', textDirection: Directionality.of(context), excludeSemantics: true, child: const SizedBox.expand());
    }
    // Not wrapped in IgnorePointer: that would also block the tap and focus actions that screen
    // readers send. The box paints nothing and has no hit target, so touches fall through to the
    // figure below, which does the hit testing with its margin.
    return Positioned.fromRect(rect: rect, child: content);
  }

  Widget _badge(PxDsBodyRegion r, String text, double scale, PxDsThemeData ds) {
    final c = ds.colors;
    return Positioned(
      left: r.labelPoint.dx * scale,
      top: r.labelPoint.dy * scale,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: ExcludeSemantics(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: c.colorSurfaceDefault,
                borderRadius: const BorderRadius.all(Radius.circular(PxDsTokens.radiusFull)),
                border: Border.all(color: c.colorBorderControl, width: PxDsTokens.borderWidthHairline),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: PxDsTokens.space2, vertical: 1),
                child: Text(text, maxLines: 1, style: ds.type.textLabelSm.copyWith(color: c.colorTextDefault)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FigurePainter extends CustomPainter {
  _FigurePainter({
    required this.face,
    required this.colors,
    required this.selected,
    required this.disabled,
    required this.selecting,
    required this.hover,
    required this.pressed,
    required this.focused,
  });

  final PxDsBodyFace face;
  final PxDsColors colors;
  final Set<PxDsBodyRegion> selected;
  final Set<PxDsBodyRegion> disabled;
  final bool selecting;
  final PxDsBodyRegion? hover;
  final PxDsBodyRegion? pressed;
  final PxDsBodyRegion? focused;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / pxDsBodyViewBox.width;
    canvas.scale(k);
    final regions = PxDsBodyRegion.onFace(face);
    final hairline = PxDsTokens.borderWidthHairline / k;
    final thick = PxDsTokens.borderWidthThick / k;

    final fill = Paint()..style = PaintingStyle.fill;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    for (final r in regions) {
      final path = _paths[r]!;
      final on = selected.contains(r);
      fill.color = on && !disabled.contains(r) ? colors.colorActionPrimaryBg : colors.colorSurfaceSunken;
      canvas.drawPath(path, fill);
      if (selecting && !disabled.contains(r)) {
        final layer = r == pressed ? PxDsTokens.opacityStatePressed : (r == hover ? PxDsTokens.opacityStateHover : 0.0);
        if (layer > 0) {
          // The state layer is the text colour over the fill, so it darkens or lightens in every theme.
          canvas.drawPath(path, fill..color = (on ? colors.colorActionPrimaryFg : colors.colorTextDefault).withValues(alpha: layer));
        }
      }
    }
    for (final r in regions) {
      line
        ..strokeWidth = hairline
        ..color = disabled.contains(r) ? colors.colorBorderSubtle : colors.colorBorderControl;
      canvas.drawPath(_paths[r]!, line);
    }
    // Selected regions get a thicker outline as well as the fill, so the choice is not colour alone.
    for (final r in regions) {
      if (!selected.contains(r) || disabled.contains(r)) continue;
      line
        ..strokeWidth = thick
        ..color = colors.colorBorderStrong;
      canvas.drawPath(_paths[r]!, line);
    }
    final f = focused;
    if (f != null) {
      // A ring outside the region with a gap in the surface colour; never on the fill, where the
      // ring would not be visible.
      final path = _paths[f]!;
      final gap = 2 / k, ring = PxDsTokens.borderWidthFocus / k;
      canvas.drawPath(path, line..strokeWidth = 2 * (gap + ring)..color = colors.colorFocusRing);
      canvas.drawPath(path, line..strokeWidth = 2 * gap..color = colors.colorSurfacePage);
      fill.color = selected.contains(f) ? colors.colorActionPrimaryBg : colors.colorSurfaceSunken;
      canvas.drawPath(path, fill);
      canvas.drawPath(
        path,
        line
          ..strokeWidth = selected.contains(f) ? thick : hairline
          ..color = selected.contains(f) ? colors.colorBorderStrong : colors.colorBorderControl,
      );
    }
  }

  @override
  bool shouldRepaint(_FigurePainter old) =>
      old.face != face ||
      old.colors != colors ||
      old.selecting != selecting ||
      old.hover != hover ||
      old.pressed != pressed ||
      old.focused != focused ||
      !_same(old.selected, selected) ||
      !_same(old.disabled, disabled);

  static bool _same(Set<PxDsBodyRegion> a, Set<PxDsBodyRegion> b) => a.length == b.length && a.containsAll(b);
}

/// The list alternative: the same regions as checkboxes, grouped by area, bound to the same
/// selection.
class _RegionList extends StatelessWidget {
  const _RegionList({required this.strings, required this.selected, required this.disabled, required this.enabled, required this.onToggle});

  final PxDsBodyStrings strings;
  final Set<PxDsBodyRegion> selected;
  final Set<PxDsBodyRegion> disabled;
  final bool enabled;
  final ValueChanged<PxDsBodyRegion> onToggle;

  static const _groups = <(Set<String>, String Function(PxDsBodyStrings))>[
    ({'head', 'neck'}, _headNeck),
    ({'shoulder', 'upper-arm', 'elbow', 'forearm', 'hand'}, _arms),
    ({'chest', 'abdomen-upper', 'abdomen-lower', 'hip', 'groin'}, _torso),
    ({'upper-back', 'mid-back', 'lower-back', 'tailbone', 'buttock'}, _back),
    ({'thigh', 'knee', 'shin', 'calf', 'ankle', 'foot', 'heel'}, _legs),
  ];
  static String _headNeck(PxDsBodyStrings s) => s.groupHeadNeck;
  static String _arms(PxDsBodyStrings s) => s.groupArms;
  static String _torso(PxDsBodyStrings s) => s.groupTorso;
  static String _back(PxDsBodyStrings s) => s.groupBack;
  static String _legs(PxDsBodyStrings s) => s.groupLegs;

  @override
  Widget build(BuildContext context) {
    final ds = PxDsThemeData.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (areas, title) in _groups) ...[
          Padding(
            padding: const EdgeInsets.only(top: PxDsTokens.space4, bottom: PxDsTokens.space1),
            child: Semantics(header: true, child: Text(title(strings), style: ds.type.textTitleSm.copyWith(color: ds.colors.colorTextDefault))),
          ),
          for (final r in PxDsBodyRegion.values.where((r) => areas.contains(r.area)))
            PxDsCheckbox(
              label: strings.region(r),
              value: selected.contains(r),
              onChanged: enabled && !disabled.contains(r) ? (_) => onToggle(r) : null,
            ),
        ],
      ],
    );
  }
}
