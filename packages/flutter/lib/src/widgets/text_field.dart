import 'package:flutter/material.dart';

import '../icons/icons.g.dart';
import '../tokens/tokens.g.dart';
import 'icon.dart';
import 'theme_access.dart';

/// Field (INP-16 with INP-01/02 controls, INP-14 Label, INP-15 Helper/error text). Built on
/// Material's [TextField].
///
/// * The label is always visible above the field, never only a placeholder.
/// * [helper] sits below; [error] replaces it with an icon and words (never a red border alone)
///   and the border turns color-feedback-danger-fg at 2px.
/// * Screen readers get the label, "required", and the helper or error with the field.
class PxDsTextField extends StatelessWidget {
  const PxDsTextField({
    super.key,
    required this.label,
    this.controller,
    this.helper,
    this.error,
    this.placeholder,
    this.required = false,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController? controller;
  final String? helper;

  /// Message to show; validation is the caller's. Non-null marks the field invalid.
  final String? error;
  final String? placeholder;
  final bool required;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;

  /// More than 1 for a text area.
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final ds = PxDsThemeData.of(context);
    final c = ds.colors;
    final t = ds.type;
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(PxDsTokens.radiusMd)),
          borderSide: BorderSide(color: color, width: width),
        );
    final hasError = error != null;
    final rest = hasError ? border(c.colorFeedbackDangerFg, PxDsTokens.borderWidthThick) : border(c.colorBorderControl, PxDsTokens.borderWidthHairline);
    final messageStyle = t.textCaptionSm.copyWith(color: hasError ? c.colorFeedbackDangerFg : c.colorTextMuted);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Text.rich(TextSpan(children: [
            TextSpan(text: label, style: t.textLabelMd.copyWith(color: c.colorTextDefault)),
            if (required) TextSpan(text: ' *', style: t.textLabelMd.copyWith(color: c.colorFeedbackDangerFg)),
          ])),
        ),
        const SizedBox(height: PxDsTokens.space2),
        // One node for screen readers: label, "required", value, helper or error.
        MergeSemantics(
          child: Semantics(
          label: required ? '$label, required' : label,
          child: TextField(
            controller: controller,
            enabled: enabled,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            maxLines: obscureText ? 1 : maxLines,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: t.textBodyMd.copyWith(color: c.colorTextDefault),
            cursorColor: c.colorTextDefault,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: c.colorSurfaceDefault,
              hintText: placeholder,
              hintStyle: t.textBodyMd.copyWith(color: c.colorTextMuted),
              contentPadding: const EdgeInsets.symmetric(horizontal: PxDsTokens.space3, vertical: PxDsTokens.space3),
              constraints: const BoxConstraints(minHeight: PxDsTokens.sizeControlLg),
              enabledBorder: rest,
              disabledBorder: border(c.colorBorderSubtle, PxDsTokens.borderWidthHairline),
              focusedBorder: hasError ? rest : border(c.colorFocusRing, PxDsTokens.borderWidthFocus),
              errorBorder: rest,
              focusedErrorBorder: rest,
              border: rest,
              helperText: hasError ? null : helper,
              helperStyle: messageStyle,
              helperMaxLines: 3,
              error: hasError
                  ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1, right: PxDsTokens.space1),
                        child: PxDsIcon(PxDsIcons.xCircle, size: PxDsTokens.sizeIconSm, color: c.colorFeedbackDangerFg),
                      ),
                      Expanded(child: Text(error!, style: messageStyle)),
                    ])
                  : null,
            ),
          ),
          ),
        ),
      ],
    );
  }
}
