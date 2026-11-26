<!-- Polinom.io shared AI context v1.25.0. Managed centrally; don't edit it here. -->

# Engineering standards

## Repository Structure

- Every repository should always contain the following files: 
  - README.md
  - .gitignore
  - CODEOWNERS
  - .ai folder with
    - project-overview.md (repo-owned, not synced: what the product does, users, architecture)
    - business-rules.md (repo-owned, not synced: domain rules the code must keep)

- `.gitignore` = the template's generic part + one block per declared `stack-*` topic, pasted from the template's `gitignore/<stack>.gitignore` above the secrets block, which stays last. No `!` lines except `!*.example` after the secrets header. Existing repos add their block when next touched.

- Load `.ai/` context lazily. CLAUDE.md @-imports only `.ai/global.md`, `.ai/engineering/engineering.md` (commit, signing and branch rules apply to almost every session) and, in private repos, `.ai/data-and-security.md`. AGENTS.md lists the other `.ai/` files, each with a "read when" trigger, and you read a file when its trigger applies:
  - `project-overview.md`: before planning, scoping or explaining work in this repo.
  - `business-rules.md`: before changing domain logic, data models or validations.
  - `engineering/security-rules.md` (private repos): before touching auth, secrets, dependencies, CI permissions or personal data.
  - `engineering/tech-stacks/tech-stacks.md`, then the stack files present: before writing or reviewing code.
  - `engineering/testing-guidelines.md`: before writing tests or a PR test plan.
  - `engineering/cloud-providers/aws.md`: before AWS work.
  - `brand-internal.md`: before customer-facing text or documents.
  - `company-internal.md`: before invoices, contracts or account questions.
  - `company-public.md` (public repos): before describing Polinom.io publicly.

## Commits and PRs

- Conventional Commits 1.0.0: `<type>(<scope>)!: <subject>`; subject imperative, lowercase, no period, ≤ 72 chars, English.
- Types: feat, fix, perf, refactor, docs, test, build, ci, chore, style, revert. `!` or `BREAKING CHANGE:` = major.
- Squash-merge only. The PR title must be a valid conventional commit; branch commits are free-form.
- One logical change per PR. If the title needs "and", split it.
- The PR body follows the org pull request template: `## Summary`, `## Test plan` (never empty; say what was not tested), `## Checklist` with every item, and `## After merge` when someone must act manually, then `Refs #N` / `Closes #N` when an issue tracks the work. Tick a checklist item only when true and link its evidence when one exists (CI run, scan, screenshot); mark one that doesn't apply "n/a" with a reason. `gh pr create --body` skips the template: fetch it first (`gh api repos/polinom-io/.github/contents/.github/pull_request_template.md`) and copy its sections and checklist items word for word; the pr-standard check matches the exact item text. Write the body to a file and pass `--body-file` (gh api: `-F body=@<file>`); on laptops set up by px-context, a Claude Code hook runs the pr-standard checks first and blocks a non-compliant title or body. Where that hook is not installed (cloud sessions, other agents), run the same checks yourself before creating or editing the PR: `title_problems()` and `body_problems()` from px-context `scripts/hooks/check-pr-standard.py` must both return nothing. Bots (release-please, context sync, Dependabot) are exempt.

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

## Tracking work

- One issue per deliverable, small enough to close with one or a few PRs. The PR that finishes it says `Closes #N`.
- Group related issues as sub-issues of a short parent issue. The parent body holds only the goal and the decision link; progress is its sub-issue list, which GitHub keeps current.
- Never rewrite an issue body to report progress. Post a comment instead (date, what changed, links), so the history stays visible and parallel sessions don't overwrite each other.
- Work in another repo gets its own issue there, linked as a sub-issue. Public repos never link back to a private repo's issues; the private issue links to the public work.

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
- Template repos never release: their release-please job carries `if: ${{ !github.event.repository.is_template }}`, and they keep an empty manifest (`{}`), `version.txt` at `0.0.0` and no `CHANGELOG.md`, so new repos start clean.
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
- Security scans: every repo calls the org's shared `security.yml` on pull requests, on push to `main` and on the org cadence, `cron: "0 6 * * 1"` (weekly, Monday 06:00 UTC). Don't pick another schedule.

## Human setup steps
- When you ask a human to create a secret, token, key, account setting or cloud resource, ship a setup script in the repo that owns it, plus a README section, not bare console steps.
- The script does everything the API allows. For each manual part it prints the exact console steps, the direct URL and the permission to set on each field.
- The script reads secrets with hidden input (`read -s`) and passes them on stdin (e.g. `gh secret set NAME` reading stdin), never as arguments, files or output.
- Exception: a one-off manual step the API can't do (a UI toggle) needs no script; give its direct URL and note it in the README.

## Tech stacks

- Every repo declares its stacks as GitHub topics (`stack-<name>`); the sync copies only those stack files into `.ai/engineering/tech-stacks/`. Read the ones present before working in a repo, starting with `tech-stacks.md`.

## Code style
- Lint/format with Biome using the shared `@polinom-io/biome-config`; don't restate its rules. Never add ESLint or Prettier, or the archived `@polinom.io/eslint-config` and `@polinom.io/prettier-config`.
- Tests and fixtures use synthetic data only.
