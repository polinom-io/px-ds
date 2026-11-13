<!-- px-context v1.3.0. Synced from polinom-io/px-context; edit it there, not here. -->

<!-- px-context:visibility=public -->
# Engineering standards

## Repository Structure

- Every repository should always contain the following files: 
  - README.md
  - .gitignore
  - CODEOWNERS
  - .ai folder with
    - project-overview.md
    - business-rules.md

## Commits and PRs

- Conventional Commits 1.0.0: `<type>(<scope>)!: <subject>`; subject imperative, lowercase, no period, ≤ 72 chars, English.
- Types: feat, fix, perf, refactor, docs, test, build, ci, chore, style, revert. `!` or `BREAKING CHANGE:` = major.
- Squash-merge only. The PR title must be a valid conventional commit; branch commits are free-form.
- One logical change per PR. If the title needs "and", split it.

## Commit signing

- Every commit is signed, on every branch: `main` in every `polinom-io` repo rejects PRs with unsigned commits.
- One-time laptop setup: `gpg --full-generate-key` (ed25519, your @polinom.io email), add the public key at https://github.com/settings/keys, then `git config --global user.signingkey <KEY_ID>`, `commit.gpgsign true` and `tag.gpgsign true`. Turn on GitHub vigilant mode.
- The key's email must match `git config user.email` and be verified on GitHub, or commits show as Unverified.
- Agents never sign with someone else's key or disable signing (`--no-gpg-sign`, `commit.gpgsign=false`). If signing fails, stop and ask.
- If a PR is blocked by unsigned commits, recreate them as signed commits on a new branch; don't force-push without asking.
- Private keys stay on the laptop or a hardware key, never in a repo, secret store or prompt. Lost or leaked key: revoke it on GitHub and generate a new one.

## Releases

- Every repo releases with release-please (`googleapis/release-please-action@v4`) using `release-please-config.json` and `.release-please-manifest.json`, with `include-component-in-tag: false` so tags are `vX.Y.Z`. It keeps a release PR open with the version bump and CHANGELOG; merging it tags, creates the GitHub release and triggers publishing. Only `feat`, `fix`, `perf`, `revert` and breaking changes produce a release; `docs`, `chore`, `ci` and the rest don't.
- Never bump versions, edit `CHANGELOG.md`, push tags or create GitHub releases by hand. To force a version, put `Release-As: x.y.z` in a commit body.
- Publish jobs run in the release-please workflow, gated on its `release_created` output: tags and releases made with `GITHUB_TOKEN` don't trigger other workflows.
- Packages: publish to **GitHub Packages** under the `@polinom-io` scope (`https://npm.pkg.github.com`), from GitHub Actions only, never from a laptop. Never publish to npmjs.org, and never create new `@polinom.io` packages.
- Consumers map the scope once in `~/.npmrc`: `@polinom-io:registry=https://npm.pkg.github.com` plus `//npm.pkg.github.com/:_authToken=<token with read:packages>`. Never commit the token.
- Legacy: `@polinom.io/*` on npmjs.org is frozen. When one of those packages next changes, republish it as `@polinom-io/<name>` on GitHub Packages and `npm deprecate` the old one.

## CI/CD
- GitHub Actions only. Secrets in org/repo secrets, never in workflow files.
- Workflows that commit or open PRs use `GITHUB_TOKEN` or a GitHub App token with signed commits (e.g. `sign-commits: true` in `peter-evans/create-pull-request`), never a personal access token: commits made with a personal token are unsigned and get blocked.
- Cloud deploys use OIDC (`id-token: write`), not long-lived keys.

## Code style
- Lint/format with the shared configs (today the legacy `@polinom.io/eslint-config` and `@polinom.io/prettier-config`; `@polinom-io/*` once republished); don't restate their rules.
- Tests and fixtures use synthetic data only.
