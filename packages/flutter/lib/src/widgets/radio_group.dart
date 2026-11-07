import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/tokens.g.dart';
import 'field_message.dart';
import 'selection_row.dart';
import 'theme_access.dart';

/// One choice in a [PxDsRadioGroup].
@immutable
class PxDsRadioOption<T> {
  const PxDsRadioOption({required this.value, required this.label, this.description, this.enabled = true});
  final T value;
  final String label;
  final String? description;
  final bool enabled;
}

/// Radio group (INP-06, Group variant): exactly one choice from a short list, with a heading.
///
/// * [label] names the question ("How often?") and is read before the options.
/// * Keyboard follows the WAI-ARIA radio group: Tab enters and leaves the group at the selected
///   option (or the first); the arrow keys move to the next or previous option and select it,
///   wrapping at the ends and skipping disabled options.
/// * Selected: a 2px color-action-primary-bg ring with a dot; unselected: a hairline
///   color-border-control ring.
/// * [error] shows an icon and message under the options and is read with the heading.
/// * More than about 6 options, or options the user must scroll to compare: use a Select.
class PxDsRadioGroup<T> extends StatefulWidget {
  const PxDsRadioGroup({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.helper,
    this.error,
    this.required = false,
  });

  final String label;
  final List<PxDsRadioOption<T>> options;

  /// The selected value, or null for none yet.
  final T? value;

  /// Null disables the whole group.
  final ValueChanged<T>? onChanged;
  final String? helper;

  /// Message to show; validation is the caller's.
  final String? error;
  final bool required;

  @override
  State<PxDsRadioGroup<T>> createState() => _PxDsRadioGroupState<T>();
}

class _PxDsRadioGroupState<T> extends State<PxDsRadioGroup<T>> {
  final _nodes = <FocusNode>[];

  void _syncNodes() {
    while (_nodes.length < widget.options.length) {
      _nodes.add(FocusNode(debugLabel: 'PxDsRadioGroup option ${_nodes.length}'));
    }
    while (_nodes.length > widget.options.length) {
      _nodes.removeLast().dispose();
    }
  }

  bool _enabled(int i) => widget.onChanged != null && widget.options[i].enabled;

  /// The option Tab lands on: the selected one, else the first enabled one.
  int get _tabStop {
    final selected = widget.options.indexWhere((o) => o.value == widget.value);
    if (selected >= 0 && _enabled(selected)) return selected;
    final first = Iterable<int>.generate(widget.options.length).where(_enabled);
    return first.isEmpty ? -1 : first.first;
  }

  void _move(int from, int step) {
    final n = widget.options.length;
    for (var k = 1; k <= n; k++) {
      final i = (from + step * k) % n;
      if (_enabled(i)) {
        widget.onChanged!(widget.options[i].value);
        _nodes[i].requestFocus();
        return;
      }
    }
  }

  @override
  void dispose() {
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _syncNodes();
    final ds = PxDsThemeData.of(context);
    final c = ds.colors;
    final stop = _tabStop;
    for (var i = 0; i < _nodes.length; i++) {
      _nodes[i].skipTraversal = i != stop;
    }
    const dot = PxDsTokens.sizeIconMd;

    Widget option(int i) {
      final o = widget.options[i];
      final selected = o.value == widget.value;
      return Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
          final key = event.logicalKey;
          if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.arrowRight) {
            _move(i, 1);
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.arrowLeft) {
            _move(i, -1);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: PxDsSelectionRow(
          label: o.label,
          description: o.description,
          checked: selected,
          inMutuallyExclusiveGroup: true,
          focusNode: _nodes[i],
          onTap: _enabled(i) ? () => widget.onChanged!(o.value) : null,
          control: (states) => PxDsFocusFrame(
            focused: states.contains(WidgetState.focused),
            radius: dot / 2,
            child: Container(
              width: dot,
              height: dot,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.colorSurfaceDefault,
                border: widget.error != null
                    ? Border.all(color: c.colorFeedbackDangerFg, width: PxDsTokens.borderWidthThick)
                    : selected
                        ? Border.all(color: c.colorActionPrimaryBg, width: PxDsTokens.borderWidthThick)
                        : Border.all(color: c.colorBorderControl, width: PxDsTokens.borderWidthHairline),
              ),
              foregroundDecoration: BoxDecoration(shape: BoxShape.circle, color: pxDsStateLayer(states, c.colorTextDefault)),
              child: selected
                  ? Container(
                      key: const Key('px-radio-dot'),
                      width: dot / 2,
                      height: dot / 2,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: widget.error != null ? c.colorFeedbackDangerFg : c.colorActionPrimaryBg),
                    )
                  : null,
            ),
          ),
        ),
      );
    }

    final heading = widget.required ? '${widget.label}, required' : widget.label;
    final groupLabel = [heading, widget.error ?? widget.helper].whereType<String>().join(', ');
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: groupLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: Text.rich(TextSpan(children: [
              TextSpan(text: widget.label, style: ds.type.textLabelMd.copyWith(color: c.colorTextDefault)),
              if (widget.required) TextSpan(text: ' *', style: ds.type.textLabelMd.copyWith(color: c.colorFeedbackDangerFg)),
            ])),
          ),
          const SizedBox(height: PxDsTokens.space1),
          for (var i = 0; i < widget.options.length; i++) option(i),
          PxDsFieldMessage(helper: widget.helper, error: widget.error),
        ],
      ),
    );
  }
}
