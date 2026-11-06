<!-- px-context v0.1.1. Synced from polinom-io/px-context; edit it there, not here. -->

<!-- px-context:visibility=public -->
# Engineering standards

## Commits and PRs
- Conventional Commits 1.0.0: `<type>(<scope>)!: <subject>`; subject imperative, lowercase, no period, ≤ 72 chars, English.
- Types: feat, fix, perf, refactor, docs, test, build, ci, chore, style, revert. `!` or `BREAKING CHANGE:` = major.
- Squash-merge only. The PR title must be a valid conventional commit; branch commits are free-form.
- One logical change per PR. If the title needs "and", split it.

## Releases
- `release-please` opens a release PR with version bump and CHANGELOG; merging it tags and publishes.
- npm: `npm publish --provenance` from GitHub Actions only, never from a laptop.

## CI/CD
- GitHub Actions only. Secrets in org/repo secrets, never in workflow files.
- Cloud deploys use OIDC (`id-token: write`), not long-lived keys.

## Code style
- Lint/format with `@polinom.io/eslint-config` and `@polinom.io/prettier-config`; don't restate their rules.
- Tests and fixtures use synthetic data only.
