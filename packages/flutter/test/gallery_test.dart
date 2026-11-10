@Tags(['gallery'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:px_ds/px_ds.dart';

import 'support.dart';

/// Renders every widget in the four themes with the real fonts, for visual review.
/// CI runs it with --update-goldens and uploads test/goldens/ as an artifact; it is not a
/// pass/fail comparison until baselines are approved and committed.
void main() {
  setUpAll(loadBundledFonts);

  Widget column(PxDsBrand brand, Brightness b) => Theme(
        data: ThemeData(brightness: b, extensions: PxDsTheme.extensions(brand, b)),
        child: Builder(builder: (context) {
          final c = Theme.of(context).extension<PxDsColors>()!;
          final t = Theme.of(context).extension<PxDsTypography>()!;
          return Container(
            width: 400,
            color: c.colorSurfacePage,
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('${brand.name} · ${b.name}', style: t.textLabelMd.copyWith(color: c.colorTextMuted)),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                PxDsButton(label: 'Start a project', onPressed: () {}),
                PxDsButton(label: 'See our approach', variant: PxDsButtonVariant.secondary, onPressed: () {}),
                PxDsButton(label: 'Cancel', variant: PxDsButtonVariant.ghost, onPressed: () {}),
                PxDsButton(label: 'Delete', variant: PxDsButtonVariant.danger, onPressed: () {}),
                const PxDsButton(label: 'Disabled', onPressed: null),
                PxDsButton(label: 'Small', size: PxDsButtonSize.sm, onPressed: () {}),
              ]),
              const SizedBox(height: 16),
              const PxDsTextField(label: 'Work email', required: true, helper: 'We reply within one business day.'),
              const SizedBox(height: 12),
              const PxDsTextField(label: 'Company', error: 'Enter your company name.'),
              const SizedBox(height: 16),
              const PxDsAlert(tone: PxDsAlertTone.warning, title: 'Spanish copy needs review', body: 'First-pass translation.'),
              const SizedBox(height: 8),
              const PxDsAlert(tone: PxDsAlertTone.success, title: 'Saved'),
              const SizedBox(height: 8),
              const PxDsAlert(tone: PxDsAlertTone.info, title: 'Heads up'),
              const SizedBox(height: 8),
              const PxDsAlert(tone: PxDsAlertTone.danger, title: 'Payment failed'),
              const SizedBox(height: 16),
              PxDsSwitch(label: 'Reminders', description: 'Daily at 9:00', value: true, onChanged: (_) {}),
              PxDsSwitch(label: 'Share with my clinic', value: false, onChanged: (_) {}),
              const PxDsSwitch(label: 'Disabled', value: true, onChanged: null),
              PxDsCheckbox(label: 'I agree to the privacy policy', value: true, onChanged: (_) {}),
              PxDsCheckbox(label: 'Select all', value: null, tristate: true, onChanged: (_) {}),
              PxDsCheckbox(label: 'Accept the terms', value: false, error: 'Accept the terms to continue.', onChanged: (_) {}),
              const SizedBox(height: 8),
              PxDsRadioGroup<String>(
                label: 'How often?',
                required: true,
                value: 'daily',
                onChanged: (_) {},
                options: const [
                  PxDsRadioOption(value: 'daily', label: 'Every day'),
                  PxDsRadioOption(value: 'weekly', label: 'Every week', description: 'On Mondays'),
                  PxDsRadioOption(value: 'never', label: 'Never', enabled: false),
                ],
              ),
              const SizedBox(height: 16),
              PxDsDialog(
                title: 'Delete this entry?',
                message: "This removes the pain entry from your history. You can't undo this.",
                alert: true,
                actions: [
                  PxDsButton(label: 'Keep entry', variant: PxDsButtonVariant.ghost, onPressed: () {}),
                  PxDsButton(label: 'Delete entry', variant: PxDsButtonVariant.danger, onPressed: () {}),
                ],
              ),
              const SizedBox(height: 8),
              PxDsDialog(title: 'Reminder time', message: 'Choose when we remind you to log pain.', actions: [PxDsButton(label: 'Save', onPressed: () {})]),
              const SizedBox(height: 16),
              const PxDsCard(tone: PxDsTone.secondary, exponent: 'x³', title: 'Strategy', body: 'The highest-degree term.'),
              const SizedBox(height: 16),
              const PxDsBodyOutline(
                label: 'Where it hurt',
                size: PxDsBodySize.medium,
                layout: PxDsBodyLayout.sideBySide,
                selected: {PxDsBodyRegion.kneeLeftFront, PxDsBodyRegion.lowerBackLeftBack},
                labels: {PxDsBodyRegion.kneeLeftFront: '7/10', PxDsBodyRegion.lowerBackLeftBack: '4/10'},
              ),
              const SizedBox(height: 16),
              Wrap(spacing: 12, runSpacing: 12, children: [
                for (final icon in PxDsIcons.all) PxDsIcon(icon, size: 24, color: c.colorTextDefault),
              ]),
              const SizedBox(height: 16),
              for (final role in [('Display', t.textDisplayMd), ('Heading', t.textHeadingLg), ('Title', t.textTitleMd), ('Body text, regular', t.textBodyMd), ('Label 500', t.textLabelMd), ('code_md()', t.textCodeMd)])
                Text(role.$1, style: role.$2.copyWith(color: c.colorTextDefault)),
            ]),
          );
        }),
      );

  testWidgets('gallery: all widgets in the four themes', (tester) async {
    tester.view.physicalSize = const Size(1600, 2500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(extensions: PxDsTheme.extensions(PxDsBrand.px, Brightness.light)),
      home: Material(
        child: SingleChildScrollView(
          child: RepaintBoundary(
            key: const Key('gallery'),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              column(PxDsBrand.px, Brightness.light),
              column(PxDsBrand.px, Brightness.dark),
              column(PxDsBrand.treatmint, Brightness.light),
              column(PxDsBrand.treatmint, Brightness.dark),
            ]),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await expectLater(find.byKey(const Key('gallery')), matchesGoldenFile('goldens/gallery.png'));
  });
}
