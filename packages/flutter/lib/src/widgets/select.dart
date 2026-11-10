import 'dart:ui' show SemanticsValidationResult;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../icons/icons.g.dart';
import '../tokens/tokens.g.dart';
import 'field_message.dart';
import 'icon.dart';
import 'theme_access.dart';

/// One choice in a [PxDsSelect].
class PxDsSelectOption<T> {
  const PxDsSelectOption({required this.value, required this.label, this.enabled = true});

  final T value;
  final String label;

  /// A disabled option is listed but can't be picked.
  final bool enabled;
}

/// Select (INP-03): pick one value from a list that opens under the field.
///
/// * The label is always visible above the field; [placeholder] shows only while nothing is
///   picked, and never replaces the label.
/// * The chosen option carries a check as well as its place in the list, so the choice never
///   relies on colour alone. [error] replaces [helper] and carries the x-circle icon.
/// * Keyboard: Tab to the field, Enter, Space or Down open it, arrows move through the options,
///   Enter picks, Esc closes and returns focus to the field.
/// * Screen readers get the label, "required", the current value and the helper or error, and
///   hear it as a button that is expanded or collapsed.
/// * For a short list shown all at once, use [PxDsRadioGroup]; for a long or searchable one, a
///   combobox is the right control, which this is not.
///
/// Built on Material's [MenuAnchor] for the menu, focus and keyboard handling.
class PxDsSelect<T> extends StatefulWidget {
  const PxDsSelect({
    super.key,
    required this.label,
    required this.options,
    required this.onChanged,
    this.value,
    this.helper,
    this.error,
    this.placeholder,
    this.required = false,
    this.enabled = true,
  });

  final String label;
  final List<PxDsSelectOption<T>> options;

  /// The picked value, or null for none. Controlled: the screen keeps it and updates it from
  /// [onChanged].
  final T? value;
  final ValueChanged<T> onChanged;
  final String? helper;

  /// Message to show; validation is the caller's. Non-null marks the field invalid.
  final String? error;
  final String? placeholder;
  final bool required;
  final bool enabled;

  @override
  State<PxDsSelect<T>> createState() => _PxDsSelectState<T>();
}

class _PxDsSelectState<T> extends State<PxDsSelect<T>> {
  final _menu = MenuController();
  final _focus = FocusNode(debugLabel: 'PxDsSelect');
  var _open = false;
  var _focused = false;

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  PxDsSelectOption<T>? get _selected {
    for (final o in widget.options) {
      if (o.value == widget.value) return o;
    }
    return null;
  }

  void _toggle() {
    if (!widget.enabled) return;
    _menu.isOpen ? _menu.close() : _menu.open();
  }

  @override
  Widget build(BuildContext context) {
    final ds = PxDsThemeData.of(context);
    final c = ds.colors;
    final t = ds.type;
    final hasError = widget.error != null;
    final selected = _selected;
    const shape = BorderRadius.all(Radius.circular(PxDsTokens.radiusMd));

    final Color borderColor;
    final double borderWidth;
    if (!widget.enabled) {
      borderColor = c.colorBorderSubtle;
      borderWidth = PxDsTokens.borderWidthHairline;
    } else if (hasError) {
      borderColor = c.colorFeedbackDangerFg;
      borderWidth = PxDsTokens.borderWidthThick;
    } else if (_focused || _open) {
      borderColor = c.colorFocusRing;
      borderWidth = PxDsTokens.borderWidthFocus;
    } else {
      borderColor = c.colorBorderControl;
      borderWidth = PxDsTokens.borderWidthHairline;
    }
    final textColor = widget.enabled ? c.colorTextDefault : c.colorTextDisabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Text.rich(TextSpan(children: [
            TextSpan(text: widget.label, style: t.textLabelMd.copyWith(color: c.colorTextDefault)),
            if (widget.required) TextSpan(text: ' *', style: t.textLabelMd.copyWith(color: c.colorFeedbackDangerFg)),
          ])),
        ),
        const SizedBox(height: PxDsTokens.space2),
        LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth;
          return MenuAnchor(
            controller: _menu,
            onOpen: () => setState(() => _open = true),
            onClose: () => setState(() => _open = false),
            style: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(c.colorSurfaceRaised),
              surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
              shadowColor: const WidgetStatePropertyAll(Colors.transparent),
              elevation: const WidgetStatePropertyAll(0),
              padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: PxDsTokens.space1)),
              minimumSize: WidgetStatePropertyAll(Size(width, 0)),
              maximumSize: WidgetStatePropertyAll(Size(width, double.infinity)),
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                borderRadius: shape,
                side: BorderSide(color: c.colorBorderControl, width: PxDsTokens.borderWidthHairline),
              )),
            ),
            menuChildren: [
              for (final o in widget.options)
                Semantics(
                  selected: o.value == widget.value,
                  child: MenuItemButton(
                    onPressed: o.enabled ? () => widget.onChanged(o.value) : null,
                    style: ButtonStyle(
                      minimumSize: const WidgetStatePropertyAll(Size(0, PxDsTokens.sizeControlLg)),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: PxDsTokens.space3)),
                      textStyle: WidgetStatePropertyAll(t.textBodyMd),
                      foregroundColor: WidgetStateProperty.resolveWith(
                        (s) => s.contains(WidgetState.disabled) ? c.colorTextDisabled : c.colorTextDefault,
                      ),
                      iconColor: WidgetStatePropertyAll(c.colorTextDefault),
                      overlayColor: WidgetStateProperty.resolveWith((s) {
                        if (s.contains(WidgetState.pressed)) return c.colorTextDefault.withValues(alpha: PxDsTokens.opacityStatePressed);
                        if (s.contains(WidgetState.hovered) || s.contains(WidgetState.focused)) {
                          return c.colorTextDefault.withValues(alpha: PxDsTokens.opacityStateHover);
                        }
                        return null;
                      }),
                    ),
                    trailingIcon: o.value == widget.value ? const PxDsIcon(PxDsIcons.check, size: PxDsTokens.sizeIconMd) : null,
                    child: Text(o.label),
                  ),
                ),
            ],
            builder: (context, controller, _) => CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.arrowDown): () {
                  if (widget.enabled && !controller.isOpen) controller.open();
                },
              },
              child: Semantics(
                button: true,
                enabled: widget.enabled,
                expanded: _open,
                label: widget.required ? '${widget.label}, required' : widget.label,
                value: selected?.label ?? widget.placeholder ?? '',
                hint: widget.error ?? widget.helper,
                validationResult: hasError ? SemanticsValidationResult.invalid : SemanticsValidationResult.none,
                excludeSemantics: true,
                onTap: widget.enabled ? _toggle : null,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    focusNode: _focus,
                    canRequestFocus: widget.enabled,
                    onFocusChange: (f) => setState(() => _focused = f),
                    onTap: widget.enabled ? _toggle : null,
                    borderRadius: shape,
                    hoverColor: Colors.transparent,
                    child: Ink(
                      decoration: BoxDecoration(
                        color: c.colorSurfaceDefault,
                        borderRadius: shape,
                        border: Border.all(color: borderColor, width: borderWidth),
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: PxDsTokens.sizeControlLg),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: PxDsTokens.space3, vertical: PxDsTokens.space3),
                          child: Row(children: [
                            Expanded(
                              child: Text(
                                selected?.label ?? widget.placeholder ?? '',
                                style: t.textBodyMd.copyWith(color: selected == null && widget.enabled ? c.colorTextMuted : textColor),
                              ),
                            ),
                            const SizedBox(width: PxDsTokens.space2),
                            PxDsIcon(_open ? PxDsIcons.caretUp : PxDsIcons.caretDown, size: PxDsTokens.sizeIconMd, color: textColor),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
        PxDsFieldMessage(helper: widget.helper, error: widget.error),
      ],
    );
  }
}
