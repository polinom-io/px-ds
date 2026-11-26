<!-- Polinom.io shared AI context v1.23.0. Managed centrally; don't edit it here. -->

# Node.js, TypeScript and JavaScript

Applies to web apps and sites (Astro + React), serverless backends and shared npm packages.

## Versions and packages
- Pin Node in `.nvmrc` and set `engines.node`; pin pnpm with the `packageManager` field (`pnpm@x.y.z`). Never npm or yarn lockfiles.
- pnpm's shared store saves disk across repos and worktrees; never commit or copy `node_modules`.
- Monorepos use pnpm workspaces (`pnpm-workspace.yaml`) with apps and shared packages as separate workspace packages.

## Language
- TypeScript is the one language for new code (`strict: true`); never mix new JavaScript files into a TypeScript project. JavaScript stays only in legacy code; convert a file when you change it substantially.
- No `any` without a comment saying why; validate external input (HTTP bodies, env vars, third-party responses) at the boundary with a schema.

## CI
- `actions/setup-node` with `node-version-file: .nvmrc` and `cache: pnpm`, after `pnpm/action-setup`; both pinned by full commit SHA.
- `pnpm install --frozen-lockfile`, then typecheck, lint, test and build as separate steps.

## Backend (serverless on AWS)
- Follow the patterns in the org's serverless API showcase repo: one handler per function, infrastructure as code next to the code, least-privilege IAM per function.
- Configuration from environment and secret stores, never hard-coded; secrets never in the repo or in plain environment files.
- Deploy from CI with OIDC, never from a laptop.
- Instrument with OpenTelemetry (see `tech-stacks.md`, Telemetry); no vendor SDK as the instrumentation API.

## Supply chain
- Before adding a dependency: it exists on the official registry under the expected name, is maintained, and its install scripts are understood. Ask before adding one.
- Dependabot proposes updates as PRs; review them like any change.
- GitHub creates no Dependabot alerts or security updates for pnpm 12 lockfiles, so CI runs `pnpm audit --audit-level high` (dev dependencies included) on PRs that change `package.json`, `pnpm-lock.yaml` or `pnpm-workspace.yaml`, on every push to `main` and weekly (`schedule`).
- Publish only to GitHub Packages under `@polinom-io`, from GitHub Actions (see `engineering.md`, Releases).
