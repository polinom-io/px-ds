<!-- Polinom.io shared AI context v1.25.0. Managed centrally; don't edit it here. -->

# Tech stacks

Before working in a repo, read the stack files present in its `.ai/engineering/tech-stacks/`: the sync copies only the ones matching the repo's `stack-*` topics (see Declaring stacks). Rules in `engineering.md` apply to every stack; these files add only what is specific to one.

## Platforms

| Platform | Read | Where it is used |
| --- | --- | --- |
| Web (apps and sites) | `web.md`, `node-typescript.md` | Platform web; px-ds web package and tokens; the public website |
| Mobile | `flutter.md`; `swift-ios.md` for native iOS; `kotlin-android.md` for native Android | Platform app; px-ds Flutter package; iOS reference architecture repo |
| Backend | `node-typescript.md` | Platform backend; serverless API showcase repo |
| Shared tooling | `node-typescript.md` | Lint and format config packages |
| Infrastructure | the repo's own AGENTS.md | Infrastructure and context repos |

## Layers

A stack is a set of layers. **Complementary** layers are used together; a **one-of** layer has a single org choice, and an app never mixes it with an alternative; a **default** layer has an org choice that another option may replace only through a PR to these files that says why.

| Platform | Layer | Org choice | Kind | Not used |
| --- | --- | --- | --- | --- |
| Web, backend, tooling | Language | TypeScript | One-of | JavaScript in new code (legacy only) |
| Web, backend, tooling | Runtime and packages | Node.js (pinned LTS) + pnpm | One-of | npm, yarn |
| Web | Framework | Astro, for apps and sites | Default | Another framework without a PR |
| Web | UI components | React (Astro islands, px-ds React package) | One-of | Vue, Svelte, Angular |
| Web | Styling | CSS with px-ds tokens | Complementary | CSS frameworks or UI kits that duplicate px-ds |
| Web | Analytics | Google Analytics 4 | Complementary | Other trackers without review |
| Mobile | Cross-platform app | Flutter / Dart | One-of | Other cross-platform frameworks |
| Mobile | Analytics | Firebase Analytics | Complementary | Other trackers without review |
| Mobile | Native iOS | Swift + Swift Package Manager | Reference architecture only | CocoaPods, Carthage |
| Mobile | Native iOS UI | SwiftUI | One-of | UIKit in new screens (only to wrap what SwiftUI lacks) |
| Mobile | Native Android | Kotlin + Gradle (Kotlin DSL) | Only where Flutter can't do the job | Java in new code, Groovy build scripts |
| Mobile | Native Android UI | Jetpack Compose | One-of | XML Views in new screens (only to wrap what Compose lacks) |
| Backend | Compute | Serverless on AWS (Node.js + TypeScript) | One-of | — |
| All | Telemetry | OpenTelemetry (traces, metrics, logs; OTLP export) | Complementary | Vendor SDKs as the primary instrumentation |

A typical web app or site is Astro + React islands + TypeScript + px-ds tokens + Google Analytics 4 + OpenTelemetry. Changing a one-of choice, or adding a layer, needs a PR to these files first.

## Repo roles

- **Platform monorepos:** web, Flutter app and backend in one repo. Each part follows its stack file; shared code goes in a package, not copied between apps.
- **Reference and showcase repos** (iOS reference architecture, serverless API showcase): they define the pattern other projects copy. Keep them minimal, current and fully documented; a change there is a change to the standard.
- **Design system (px-ds):** the only source of design tokens for every platform (`web.md`, `flutter.md`).

## Analytics and personal data

- Analytics load only after consent, never send personal data (names, emails, RUT, IDs that identify a person) or health data, and use pseudonymous IDs. Follow `data-and-security.md` where the repo has it; Ley 21.719 applies.
- Health products send no analytics events that reveal a condition, treatment or symptom, not even in event names or parameters.

## Telemetry (OpenTelemetry)

Telemetry (how the system behaves) is separate from analytics (what people do); both follow the personal-data rules above.
- Instrument with OpenTelemetry APIs and SDKs and export over OTLP, so the telemetry backend can change without touching code. Vendor agents or SDKs only as an exporter or collector, never as the instrumentation API.
- Backend first: traces and metrics for every request, with trace context propagated across services (W3C Trace Context). On AWS Lambda, use the OpenTelemetry Lambda layer or ADOT.
- Clients (web, Flutter, Android, iOS): use the OpenTelemetry SDK for that language where it is stable enough; check its maturity before adopting it and record the decision in the stack file.
- Follow OpenTelemetry semantic conventions for names and attributes. Never put personal data, health data, tokens or request bodies in spans, metrics, logs or attributes; set `service.name` and `deployment.environment` on every service.

## Declaring stacks

Every repo declares its stacks as GitHub topics, one per stack file it uses: `stack-node-typescript`, `stack-web`, `stack-flutter`, `stack-swift-ios`, `stack-kotlin-android`. A monorepo lists every stack it contains. The context sync reads these topics and copies only the matching files, so a repo never loads rules for stacks it doesn't use.
- Set the topics when the repo is created, and update them in the same PR that adds or removes a stack (topics are repo settings, changed by a maintainer).
- A repo with no `stack-*` topics gets only this index. Repos without application code (infrastructure, context) need none.

## Adding a stack

A new language, framework or layer needs its entry here, a file and a `stack-<name>` topic (version pinning, package manager, CI setup, checks, supply chain), agreed in a PR, before the first repo uses it.
