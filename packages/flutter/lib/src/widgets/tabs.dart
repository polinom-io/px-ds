import 'dart:ui' show SemanticsRole;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/tokens.g.dart';
import 'theme_access.dart';

/// One tab of a [PxDsTabs]: its label and the content shown while it is selected.
class PxDsTab {
  const PxDsTab({required this.label, required this.content, this.enabled = true});

  final String label;
  final Widget content;

  /// A disabled tab is shown but can't be selected or focused.
  final bool enabled;
}

/// Tabs (NAV-03, line variant): switch between views of the same page without leaving it.
///
/// * The selected tab has a 2px underline in color-text-link and text in color-text-default; the
///   others are color-text-muted. The underline, not only the colour, marks the selection.
/// * Follows the WAI-ARIA tabs pattern: Tab enters the list at the selected tab, Left and Right
///   (swapped in right-to-left text) move to the next enabled tab and select it, Home and End jump
///   to the first and last. Disabled tabs are skipped.
/// * Screen readers hear a tab bar named [label], each tab as "tab, selected, n of m", and the
///   content as the tab's panel.
/// * The list scrolls sideways when the tabs don't fit; a tab you move to scrolls into view.
/// * Each tab is 48 tall, above the 44 touch minimum.
/// * Only the selected tab's content is built. Keep anything that must survive switching (a
///   scroll position, typed text) in the screen, not in the tab content.
class PxDsTabs extends StatefulWidget {
  const PxDsTabs({super.key, required this.label, required this.tabs, this.initialIndex = 0, this.onChanged});

  /// Accessible name of the tab list, e.g. "Pain history views".
  final String label;
  final List<PxDsTab> tabs;

  /// The tab selected first. A disabled or out-of-range index falls back to the first enabled tab.
  final int initialIndex;
  final ValueChanged<int>? onChanged;

  @override
  State<PxDsTabs> createState() => _PxDsTabsState();
}

class _PxDsTabsState extends State<PxDsTabs> {
  late int _index;
  late List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    assert(widget.tabs.isNotEmpty, 'Tabs needs at least one tab');
    _nodes = _makeNodes(widget.tabs.length);
    _index = _firstEnabledFrom(widget.initialIndex);
  }

  List<FocusNode> _makeNodes(int n) => [for (var i = 0; i < n; i++) FocusNode(debugLabel: 'PxDsTabs tab $i')];

  @override
  void didUpdateWidget(PxDsTabs old) {
    super.didUpdateWidget(old);
    if (old.tabs.length != widget.tabs.length) {
      for (final n in _nodes) {
        n.dispose();
      }
      _nodes = _makeNodes(widget.tabs.length);
    }
    if (_index >= widget.tabs.length || !widget.tabs[_index].enabled) _index = _firstEnabledFrom(_index);
  }

  @override
  void dispose() {
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  int _firstEnabledFrom(int start) {
    final tabs = widget.tabs;
    final from = start.clamp(0, tabs.length - 1);
    for (var i = 0; i < tabs.length; i++) {
      final j = (from + i) % tabs.length;
      if (tabs[j].enabled) return j;
    }
    return from;
  }

  void _select(int i, {bool focus = false}) {
    if (!widget.tabs[i].enabled) return;
    if (i != _index) {
      setState(() => _index = i);
      widget.onChanged?.call(i);
    }
    if (focus) {
      // After the rebuild: only the selected tab can take focus, and it is the new one by then.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || i >= _nodes.length) return;
        _nodes[i].requestFocus();
        final ctx = _nodes[i].context;
        if (ctx != null) Scrollable.ensureVisible(ctx, duration: PxDsTokens.motionDurationFast);
      });
    }
  }

  /// The next enabled tab from [from] in [step] direction, wrapping round; [from] when none.
  int _step(int from, int step) {
    final n = widget.tabs.length;
    for (var k = 1; k <= n; k++) {
      final j = (from + step * k) % n;
      final i = j < 0 ? j + n : j;
      if (widget.tabs[i].enabled) return i;
    }
    return from;
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final enabled = [for (var i = 0; i < widget.tabs.length; i++) if (widget.tabs[i].enabled) i];
    if (enabled.isEmpty) return KeyEventResult.ignored;
    final focused = _nodes.indexWhere((n) => n.hasFocus);
    final from = focused < 0 ? _index : focused;
    final key = event.logicalKey;
    final int target;
    if (key == LogicalKeyboardKey.arrowRight) {
      target = _step(from, rtl ? -1 : 1);
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      target = _step(from, rtl ? 1 : -1);
    } else if (key == LogicalKeyboardKey.home) {
      target = enabled.first;
    } else if (key == LogicalKeyboardKey.end) {
      target = enabled.last;
    } else {
      return KeyEventResult.ignored;
    }
    _select(target, focus: true);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final ds = PxDsThemeData.of(context);
    final c = ds.colors;
    final tabs = widget.tabs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.colorBorderSubtle, width: PxDsTokens.borderWidthHairline))),
          child: Focus(
            canRequestFocus: false,
            skipTraversal: true,
            onKeyEvent: _onKey,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              // The tab bar node sits directly around the tabs: its children must all be tabs.
              child: Semantics(
                role: SemanticsRole.tabBar,
                label: widget.label,
                container: true,
                child: Row(children: [
                  for (var i = 0; i < tabs.length; i++)
                    _TabButton(
                      tab: tabs[i],
                      selected: i == _index,
                      focusNode: _nodes[i],
                      // Roving focus: only the selected tab is a Tab stop.
                      tabStop: i == _index,
                      onSelect: () => _select(i, focus: true),
                    ),
                ]),
              ),
            ),
          ),
        ),
        Semantics(
          role: SemanticsRole.tabPanel,
          label: tabs[_index].label,
          container: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: PxDsTokens.space4),
            child: DefaultTextStyle.merge(style: ds.type.textBodyMd.copyWith(color: c.colorTextDefault), child: tabs[_index].content),
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatefulWidget {
  const _TabButton({required this.tab, required this.selected, required this.focusNode, required this.tabStop, required this.onSelect});

  final PxDsTab tab;
  final bool selected;
  final FocusNode focusNode;
  final bool tabStop;
  final VoidCallback onSelect;

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton> {
  var _focused = false;

  @override
  Widget build(BuildContext context) {
    final ds = PxDsThemeData.of(context);
    final c = ds.colors;
    final enabled = widget.tab.enabled;
    final Color text = !enabled ? c.colorTextDisabled : (widget.selected ? c.colorTextDefault : c.colorTextMuted);
    return Semantics(
      role: SemanticsRole.tab,
      selected: widget.selected,
      enabled: enabled,
      // One node for the tab: its label, state and actions, so screen readers read it once.
      label: widget.tab.label,
      excludeSemantics: true,
      focusable: enabled && widget.tabStop,
      focused: _focused,
      onTap: enabled ? widget.onSelect : null,
      onFocus: enabled && widget.tabStop ? widget.focusNode.requestFocus : null,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          focusNode: widget.focusNode,
          canRequestFocus: enabled && widget.tabStop,
          onFocusChange: (f) => setState(() => _focused = f),
          onTap: enabled ? widget.onSelect : null,
          borderRadius: const BorderRadius.all(Radius.circular(PxDsTokens.radiusSm)),
          hoverColor: c.colorTextDefault.withValues(alpha: PxDsTokens.opacityStateHover),
          child: Container(
            constraints: const BoxConstraints(minHeight: PxDsTokens.sizeControlLg, minWidth: PxDsTokens.sizeTouchMin),
            padding: const EdgeInsets.symmetric(horizontal: PxDsTokens.space4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(PxDsTokens.radiusSm)),
              border: _focused
                  ? Border.all(color: c.colorFocusRing, width: PxDsTokens.borderWidthFocus)
                  : Border(bottom: BorderSide(color: widget.selected ? c.colorTextLink : Colors.transparent, width: PxDsTokens.borderWidthThick)),
            ),
            child: Text(widget.tab.label, style: ds.type.textLabelMd.copyWith(color: text)),
          ),
        ),
      ),
    );
  }
}
