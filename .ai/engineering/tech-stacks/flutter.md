<!-- Polinom.io shared AI context v1.27.0. Managed centrally; don't edit it here. -->

# Flutter and Dart

Applies to mobile apps and the px-ds Flutter package.

## Versions and packages
- Pin the Flutter SDK per repo with fvm (`.fvmrc` checked in) and run `fvm flutter …` locally. fvm's shared SDK cache saves disk across repos and worktrees.
- Commit `pubspec.lock` for apps; packages commit it too in this org so CI is reproducible.
- Monorepos with multiple Flutter/Dart packages use Dart pub workspaces or Melos.

## Architecture and state management
- BLoC (`flutter_bloc`) is the one-of state management pattern for screens and feature flows; never mix in Riverpod, Provider or GetX.
- Layer boundaries:
  - Presentation: widgets and screens emitting events and reacting to BLoC states.
  - State: BLoCs coordinating domain operations.
  - Domain: pure business logic, entities, value objects and `Result<T, E>` types; no Flutter UI dependencies.
  - Storage and Data: repository implementations backed by auditable storage tiers.
- Assemble dependencies in a single composition root at application startup (`app_root.dart` or `app_start.dart`).

## Auditable storage management by data class
Every stored field and table must map to an explicit data level (see `data-and-security.md`) so access and encryption can be audited:
- **L3 Secrets and encryption keys:** `flutter_secure_storage` backed by OS Keychain / KeyStore. Set `resetOnError: false` (the default `true` wipes stored keys on transient OS read errors). iOS items must use `KeychainAccessibility.unlocked_this_device` and `synchronizable: false` (no iCloud sync of keys).
- **L4 Personal and L5 Sensitive / Health data:** Drift with SQLCipher (`sqlite3` user-defined hook) encrypted with an AES-256 key from L3 storage. Verify encryption on open (`PRAGMA cipher_version` must be non-empty; fail fast if empty). Background isolate for database operations. Schema migrations must be versioned, sequential and audited in PRs. Unencrypted SQLite is forbidden for L4/L5 data.
- **L1 Public and L2 Non-sensitive preferences:** `shared_preferences` allowed strictly for non-identifying app flags (theme mode, onboarding completed). Never put names, emails, RUT, identifiers or health data in `shared_preferences`.
- **Cloud backup exclusion:** Data directories holding L4/L5 data must opt out of OS automatic cloud backups (`android:allowBackup="false"` or backup exclusion rules on Android, `NSURLIsExcludedFromBackupKey` on iOS).
- **Auditability and logs:** Storage errors must route to typed error classes. Never log query payloads, database values or patient/personal data in logs or crash reports.

## Design
- Colours, type and spacing come from the px-ds Flutter package, never hard-coded values.
- Interactive elements must declare stable `ValueKey`s for testability (`<feature>-<action>-button`) and `Semantics` identifiers for accessibility.

## Localization
- Official Flutter localization via `l10n.yaml` and `.arb` files. Customer-facing text defaults to Spanish (Chile) (`app_es.arb`), with English (`app_en.arb`) for fallback/code.

## CI
- Install Flutter with `subosito/flutter-action`, pinned by full commit SHA, using the same version as `.fvmrc` (never just `channel: stable`). It is a community action: the Flutter team publishes none (`dart-lang/setup-dart` installs Dart only). Never reference it by tag; Dependabot proposes updates as PRs, reviewed like any dependency.
- If that action becomes unmaintained or is compromised, install Flutter in the workflow by cloning `flutter/flutter` at the pinned tag instead of switching to another third-party action.
- Run `flutter pub get`, `flutter analyze` and `flutter test` as separate steps. Unit, widget and integration tests must run without external network calls (mock external APIs at the boundary).

## Diagnostics, analytics and crash reporting
- **Firebase Analytics:** Enabled only after user consent; never send personal (names, emails, RUT) or health data in event names or parameters (see `tech-stacks.md`, Analytics and personal data). Keep Firebase config files out of public repos.
- **Firebase Crashlytics for observability:** Enabled in release builds to capture fatal crashes and uncaught exceptions (`FlutterError.onError`, `PlatformDispatcher.instance.onError`).
  - **Non-fatal errors:** Record caught exceptions in critical paths (storage corruption, crypto failures, migration errors) via `FirebaseCrashlytics.instance.recordError`.
  - **Diagnostic context:** Attach high-signal, non-sensitive custom keys (app version, build number, active feature flags, screen name) to aid crash triage.
  - **Sanitization:** Never call `setUserIdentifier` with personal data (names, RUT, emails); use pseudonymous install IDs or omit. Scrub error messages to ensure zero personal (L4) or health (L5) data enters crash reports.

## Supply chain
- Before adding a pub.dev package: verified publisher or known maintainer, recent releases, licence compatible, no unexpected native code or build hooks. Ask before adding one.
