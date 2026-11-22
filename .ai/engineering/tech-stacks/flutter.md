<!-- px-context v1.8.1. Synced from polinom-io/px-context; edit it there, not here. -->

<!-- px-context:visibility=public -->
# Flutter and Dart

Applies to mobile apps and the px-ds Flutter package.

## Versions and packages
- Pin the Flutter SDK per repo with fvm (`.fvmrc` checked in) and run `fvm flutter …` locally. fvm's shared SDK cache saves disk across repos and worktrees.
- Commit `pubspec.lock` for apps; packages commit it too in this org so CI is reproducible.

## CI
- Install Flutter with `subosito/flutter-action`, pinned by full commit SHA, using the same version as `.fvmrc` (never just `channel: stable`). It is a community action: the Flutter team publishes none (`dart-lang/setup-dart` installs Dart only). Never reference it by tag; Dependabot proposes updates as PRs, reviewed like any dependency.
- If that action becomes unmaintained or is compromised, install Flutter in the workflow by cloning `flutter/flutter` at the pinned tag instead of switching to another third-party action.
- Run `flutter pub get`, `flutter analyze` and `flutter test` as separate steps.

## Design
- Colours, type and spacing come from the px-ds Flutter package, never hard-coded values.

## Analytics
- Firebase Analytics only, enabled after consent, with no personal or health data in events (see `tech-stacks.md`, Analytics and personal data). Keep Firebase config files out of public repos.

## Supply chain
- Before adding a pub.dev package: verified publisher or known maintainer, recent releases, licence compatible, no unexpected native code or build hooks. Ask before adding one.
