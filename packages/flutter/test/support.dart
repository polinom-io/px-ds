import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:px_ds/px_ds.dart';

/// Wraps [child] in a MaterialApp with the design-system theme for [brand] and [brightness].
Widget themed(Widget child, {PxDsBrand brand = PxDsBrand.px, Brightness brightness = Brightness.light}) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: brightness, extensions: PxDsTheme.extensions(brand, brightness)),
      home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)),
    );

/// Loads the bundled fonts under the family names the text roles use (packages/px_ds/<family>),
/// so goldens show real text instead of the test font's boxes.
Future<void> loadBundledFonts() async {
  final manifest = jsonDecode(await rootBundle.loadString('FontManifest.json')) as List<dynamic>;
  for (final entry in manifest) {
    final family = (entry as Map<String, dynamic>)['family'] as String;
    final loader = FontLoader(family.startsWith('packages/') ? family : 'packages/px_ds/$family');
    for (final font in entry['fonts'] as List<dynamic>) {
      loader.addFont(rootBundle.load((font as Map<String, dynamic>)['asset'] as String));
    }
    await loader.load();
  }
}
