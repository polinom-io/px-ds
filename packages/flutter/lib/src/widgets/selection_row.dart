import 'package:flutter/material.dart';

import '../tokens/tokens.g.dart';
import 'theme_access.dart';

/// Shared row for Switch, Checkbox and Radio: the control, its label and an optional description,
/// as one focusable, tappable unit with one semantics node.
///
/// Internal. The whole row is the hit area (at least size-control-lg tall), Space and Enter
/// activate it, and [control] gets the current [WidgetState]s to draw hover, press and focus.
class PxDsSelectionRow extends StatefulWidget {
  const PxDsSelectionRow({
    super.key,
    required this.label,
    required this.onTap,
    required this.control,
    this.description,
    this.checked,
    this.mixed = false,
    this.toggled,
    this.inMutuallyExclusiveGroup = false,
    this.focusNode,
    this.semanticsSuffix,
  });

  final String label;
  final String? description;

  /// Null disables the row.
  final VoidCallback? onTap;
  final Widget Function(Set<WidgetState> states) control;
  final bool? checked;
  final bool mixed;
  final bool? toggled;
  final bool inMutuallyExclusiveGroup;
  final FocusNode? focusNode;

  /// Read after the label and description, e.g. an error message.
  final String? semanticsSuffix;

  @override
  State<PxDsSelectionRow> createState() => _PxDsSelectionRowState();
}

class _PxDsSelectionRowState extends State<PxDsSelectionRow> {
  final _states = <WidgetState>{};

  void _set(WidgetState s, bool on) {
    if (on == _states.contains(s)) return;
    setState(() => on ? _states.add(s) : _states.remove(s));
  }

  void _activate() => widget.onTap?.call();

  @override
  Widget build(BuildContext context) {
    final ds = PxDsThemeData.of(context);
    final c = ds.colors;
    final enabled = widget.onTap != null;
    final states = {..._states, if (!enabled) WidgetState.disabled};

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label, style: ds.type.textBodyMd.copyWith(color: c.colorTextDefault)),
        if (widget.description != null) Text(widget.description!, style: ds.type.textCaptionSm.copyWith(color: c.colorTextMuted)),
      ],
    );

    Widget row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: PxDsTokens.sizeControlLg),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        widget.control(states),
        const SizedBox(width: PxDsTokens.space3),
        Flexible(child: text),
      ]),
    );

    row = FocusableActionDetector(
      enabled: enabled,
      focusNode: widget.focusNode,
      mouseCursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onShowFocusHighlight: (v) => _set(WidgetState.focused, v),
      onShowHoverHighlight: (v) => _set(WidgetState.hovered, v),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
          _activate();
          return null;
        }),
        ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(onInvoke: (_) {
          _activate();
          return null;
        }),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: enabled ? _activate : null,
        onTapDown: enabled ? (_) => _set(WidgetState.pressed, true) : null,
        onTapUp: enabled ? (_) => _set(WidgetState.pressed, false) : null,
        onTapCancel: enabled ? () => _set(WidgetState.pressed, false) : null,
        child: row,
      ),
    );

    final label = [widget.label, widget.description, widget.semanticsSuffix].whereType<String>().join(', ');
    row = Semantics(
      container: true,
      excludeSemantics: true,
      enabled: enabled,
      focusable: enabled,
      focused: _states.contains(WidgetState.focused),
      checked: widget.checked,
      mixed: widget.mixed ? true : null,
      toggled: widget.toggled,
      inMutuallyExclusiveGroup: widget.inMutuallyExclusiveGroup ? true : null,
      label: label,
      onTap: enabled ? _activate : null,
      child: row,
    );

    return enabled ? row : Opacity(opacity: PxDsTokens.opacityDisabled, child: row);
  }
}

/// The focus ring around a selection control: a 2px ring with a gap the colour of the surface
/// behind it, so it stays visible on a filled control. Keeps its size when not focused.
class PxDsFocusFrame extends StatelessWidget {
  const PxDsFocusFrame({super.key, required this.focused, required this.radius, required this.child});
  final bool focused;
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = PxDsThemeData.of(context).colors;
    const ring = PxDsTokens.borderWidthFocus;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(radius + 2 * ring)),
        border: Border.all(color: focused ? c.colorFocusRing : const Color(0x00000000), width: ring),
      ),
      child: Padding(padding: const EdgeInsets.all(ring), child: child),
    );
  }
}

/// Hover and press state layer in [color] (opacity-state-hover / -pressed), or transparent.
Color pxDsStateLayer(Set<WidgetState> states, Color color) {
  if (states.contains(WidgetState.disabled)) return const Color(0x00000000);
  if (states.contains(WidgetState.pressed)) return color.withValues(alpha: PxDsTokens.opacityStatePressed);
  if (states.contains(WidgetState.hovered)) return color.withValues(alpha: PxDsTokens.opacityStateHover);
  return const Color(0x00000000);
}
