<!-- px-context v0.3.0. Synced from polinom-io/px-context; edit it there, not here. -->

<!-- px-context:visibility=public -->
# Engineering standards

## Commits and PRs
- Conventional Commits 1.0.0: `<type>(<scope>)!: <subject>`; subject imperative, lowercase, no period, ≤ 72 chars, English.
- Types: feat, fix, perf, refactor, docs, test, build, ci, chore, style, revert. `!` or `BREAKING CHANGE:` = major.
- Squash-merge only. The PR title must be a valid conventional commit; branch commits are free-form.
- One logical change per PR. If the title needs "and", split it.

## Releases
- `release-please` opens a release PR with version bump and CHANGELOG; merging it tags and publishes.
- Packages: publish to **GitHub Packages** under the `@polinom-io` scope (`https://npm.pkg.github.com`), from GitHub Actions only, never from a laptop. Never publish to npmjs.org, and never create new `@polinom.io` packages.
- Consumers map the scope once in `~/.npmrc`: `@polinom-io:registry=https://npm.pkg.github.com` plus `//npm.pkg.github.com/:_authToken=<token with read:packages>`. Never commit the token.
- Legacy: `@polinom.io/*` on npmjs.org is frozen. When one of those packages next changes, republish it as `@polinom-io/<name>` on GitHub Packages and `npm deprecate` the old one.

## CI/CD
- GitHub Actions only. Secrets in org/repo secrets, never in workflow files.
- Cloud deploys use OIDC (`id-token: write`), not long-lived keys.

## Code style
- Lint/format with the shared configs (today the legacy `@polinom.io/eslint-config` and `@polinom.io/prettier-config`; `@polinom-io/*` once republished); don't restate their rules.
- Tests and fixtures use synthetic data only.
