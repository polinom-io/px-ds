<!-- px-context v1.12.0. Synced from polinom-io/px-context; edit it there, not here. -->

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

## Branches

- `main` is the only long-lived branch. Never create `develop`, `qa`, `staging` or `release` branches, or merge one branch into another to promote changes.
- Work branches are short-lived (days, not weeks), named `<type>/<slug>` with a Conventional Commits type, and deleted on merge. The org blocks branch names with other prefixes.
- Releases are release-please tags cut from `main`; environments deploy from `main` through GitHub environments, never from a branch per environment.
- Repos allow squash merge only (merge commits and rebase merges off), with the PR title as the squash commit title.

## Parallel agent sessions

- One agent session per working folder. A second session on the same repo runs in its own git worktree (Claude Code: `claude --worktree <slug>`, created under `.claude/worktrees/`, which must be gitignored). Never a second clone, and never switch branches in a folder another session is using.
- A branch is checked out in one worktree at a time (git enforces it). Before pushing, rename the worktree branch to `<type>/<slug>` (`git branch -m`): the org blocks other prefixes, including Claude Code's default `worktree-<name>`.
- Disk: worktrees share the repo's object store, so each costs only its checkout plus dependencies. Install with pnpm (shared store, hard links) and fvm's shared SDK cache; never copy `node_modules` or build output between worktrees.
- Never list secrets in `.worktreeinclude`; set up each worktree's environment the same way as the main checkout.
- Start each session in the root folder of the repo the work belongs to (a worktree of it under `.claude/worktrees/` counts; in a monorepo, the root, not a subfolder), so that repo's AGENTS.md, `.ai/` rules and settings load. Read-only queries across repos are fine from any session; to change another repo, hand off a prompt to a session in that repo, or for a one-line mechanical change use a worktree of it after reading its AGENTS.md. Org-wide work runs from the infrastructure repo.
- Remove a worktree when its PR merges (`git worktree remove <path>`, then `git worktree prune`); keep at most 3 per repo.

## Commit signing

- Every commit is signed, on every branch: `main` in every `polinom-io` repo rejects PRs with unsigned commits.
- One-time laptop setup: `gpg --full-generate-key` (ed25519, your @polinom.io email), add the public key at https://github.com/settings/keys, then `git config --global user.signingkey <KEY_ID>`, `commit.gpgsign true` and `tag.gpgsign true`. Turn on GitHub vigilant mode.
- The key's email must match `git config user.email` and be verified on GitHub, or commits show as Unverified.
- Agents never sign with someone else's key or disable signing (`--no-gpg-sign`, `commit.gpgsign=false`). If signing fails, stop and ask.
- If a PR is blocked by unsigned commits, recreate them as signed commits on a new branch; don't force-push without asking.
- Private keys stay on the laptop or a hardware key, never in a repo, secret store or prompt. Lost or leaked key: revoke it on GitHub and generate a new one.

## Releases

- Every repo releases with release-please (`googleapis/release-please-action@v4`) using `release-please-config.json` and `.release-please-manifest.json`, with `include-component-in-tag: false` so tags are `vX.Y.Z`. It keeps a release PR open with the version bump and CHANGELOG; merging it tags, creates the GitHub release and triggers publishing. Only `feat`, `fix`, `perf`, `revert` and breaking changes produce a release; `docs`, `chore`, `ci` and the rest don't. New repos start with `"initial-version": "0.1.0"` and `"bump-minor-pre-major": true` in `release-please-config.json`; without them the first release, or the first `feat!:` on 0.x, is 1.0.0. Going to 1.0.0 is a deliberate `Release-As: 1.0.0` commit.
- Never bump versions, edit `CHANGELOG.md`, push tags or create GitHub releases by hand. To force a version, put `Release-As: x.y.z` in a commit body.
- release-please authenticates with the org's GitHub App installation token (`actions/create-github-app-token`), never `GITHUB_TOKEN` or a personal token. Its `release-please--**` branches are the only ones it may force-push; never force-push them by hand.
- Agents never approve workflow runs or re-run a workflow to get past an approval gate: ask a human with write access.
- Publish jobs run in the release-please workflow, gated on its `release_created` output: tags and releases made with `GITHUB_TOKEN` don't trigger other workflows.
- Packages: publish to **GitHub Packages** under the `@polinom-io` scope (`https://npm.pkg.github.com`), from GitHub Actions only, never from a laptop. Never publish to npmjs.org, and never create new `@polinom.io` packages.
- Consumers map the scope once in `~/.npmrc`: `@polinom-io:registry=https://npm.pkg.github.com` plus `//npm.pkg.github.com/:_authToken=<token with read:packages>`. Never commit the token.
- Legacy: `@polinom.io/*` on npmjs.org is frozen. When one of those packages next changes, republish it as `@polinom-io/<name>` on GitHub Packages and `npm deprecate` the old one.

## CI/CD
- GitHub Actions only. Secrets in org/repo secrets, never in workflow files.
- Workflows that commit or open PRs use `GITHUB_TOKEN` or a GitHub App token with signed commits (e.g. `sign-commits: true` in `peter-evans/create-pull-request`), never a personal access token: commits made with a personal token are unsigned and get blocked.
- Cloud deploys use OIDC (`id-token: write`), not long-lived keys.
- Reusable workflow first: before adding any workflow to a repo, decide whether it belongs in the org's shared workflow repos. If a shared workflow covers the job, call it pinned by full commit SHA with a `# vX.Y.Z` comment instead of copying it. If the job is generic (stack CI, release, audits, security scans) and none covers it yet, create it there first, then call it; never copy it into the repo "for now". A workflow that stays local says why in its PR (repo-specific logic). Pass each secret explicitly, never `secrets: inherit`.

## Tech stacks

- Every repo declares its stacks as GitHub topics (`stack-<name>`); the sync copies only those stack files into `.ai/engineering/tech-stacks/`. Read the ones present before working in a repo, starting with `tech-stacks.md`.

## Code style
- Lint/format with the shared configs (today the legacy `@polinom.io/eslint-config` and `@polinom.io/prettier-config`; `@polinom-io/*` once republished); don't restate their rules.
- Tests and fixtures use synthetic data only.
