<!-- px-context v1.0.0. Synced from polinom-io/px-context; edit it there, not here. -->

<!-- px-context:visibility=public -->
# Polinom.io — global defaults

Loaded on every Polinom.io laptop by `scripts/setup-ai-context.sh`. Keep it under 40 lines.

- **Brand:** always write "Polinom.io", never "Polinom". Short form: "px".
- **Language:** code, commits, docs and context files in English. Customer-facing text in the customer's language (usually Spanish, Chile).
- **Currency and locale:** CLP; dates as YYYY-MM-DD in files, DD-MM-YYYY in Spanish customer text.
- **Commits:** Conventional Commits; the PR title becomes the squash commit (see context/engineering/engineering.md).
- **Secrets:** never read, print or commit `.env*`, keys or tokens. Point to where a secret lives; don't copy it.
- **Personal data (Ley 21.719):** never put real personal data (names with RUT, emails, phones, customer records) into prompts, fixtures or logs. Use synthetic data. If a task needs real personal data, stop and ask.
- **Stop and ask a human before:** deleting data, running migrations against shared environments, `npm publish`, changing DNS or email records, force-pushing.
- **Public repos:** never copy internal context (accounts, people, infrastructure, risks, data rules) into a public repo, issue or PR. Files marked `visibility=internal` stay in private repos.
- **Accounts:** company accounts only (Claude Team seat, Google Workspace). No personal AI accounts for Polinom.io work.
