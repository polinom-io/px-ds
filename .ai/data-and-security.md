# Data and security rules for AI use

Ley 21.719 takes effect 1 Dec 2026 under current law; a bill (Boletín 18.623-07) would move it to 15 Oct 2027. These rules apply now either way. Text of the law: `legal/CL/Ley-21719_13-DIC-2024.pdf`.

## What may go into a prompt
| Data class | Examples | Company account | Claude Pro (interim) | Antigravity (terms unconfirmed) |
| --- | --- | --- | --- | --- |
| Public | Open-source code, published docs | Yes | Yes | Yes |
| Internal | Product code, budget, plans | Yes | Yes | No |
| Client confidential | Client code, contracts | Only if the contract allows | No | No |
| Personal data | Names with RUT, emails, customer records | Anonymised or synthetic; real only with legal basis | No | No |
| Sensitive personal data | Health, biometrics, profiling | Only with an approved impact assessment | No | No |

## Rules
1. AI vendors process data on Polinom.io's behalf (art. 15 bis): use accounts covered by a data processing agreement.
2. Sending data to vendors abroad is an international transfer (art. 27–28); legal basis pending counsel review.
3. A product feature that uses AI to make decisions with significant effects on people must offer explanation, human review and contest (art. 8 bis).
4. Profiling, large-scale processing or sensitive data needs an impact assessment before launch (art. 15 ter).
5. Secrets never enter prompts, context files or repos.

## Incidents
Personal data sent to a non-approved tool: tell a maintainer the same day; it is logged.
