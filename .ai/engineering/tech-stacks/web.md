<!-- px-context v1.8.1. Synced from polinom-io/px-context; edit it there, not here. -->

<!-- px-context:visibility=public -->
# Web: Astro, React, TypeScript and CSS

The default web stack is Astro + React islands + TypeScript + CSS with px-ds tokens, for apps and sites alike, instrumented with OpenTelemetry. TypeScript, Node and pnpm rules are in `node-typescript.md`.

## Astro and React
- Astro is the default framework for web apps and sites; another one only through a PR to `tech-stacks.md` that says why. React is the only UI component library, used as Astro islands and through the px-ds React package. Never add a second UI framework to an app.
- Static output by default; use server rendering or client islands only where a page needs them, and hydrate the smallest component that needs interactivity.
- Apps that handle user data (sign-in, forms, health data) follow `data-and-security.md` and validate input on the server. Public sites collect no personal data without review.

## HTML and CSS
- Colours, type, spacing and radii come from px-ds tokens (CSS variables), never hard-coded values.
- Semantic HTML first; meet WCAG 2.2 AA (contrast, keyboard access, labels, focus states).
- No CSS framework or UI kit that duplicates px-ds; ask before adding one.
- Customer-facing text in the customer's language (usually Spanish, Chile); dates as DD-MM-YYYY in that text.

## Analytics
- Google Analytics 4 only, loaded after consent, with no personal or health data in events (see `tech-stacks.md`, Analytics and personal data).
- No other third-party scripts (trackers, chat widgets, fonts from external CDNs) without review.

## CI
- Typecheck, lint and build on every PR (see `node-typescript.md`, CI).
