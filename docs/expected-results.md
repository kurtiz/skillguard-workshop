# Expected observations

Observed with the pinned SkillGuard v0.17.0 and this repository’s fixtures. Scores
are not safety certificates; read the findings and extraction coverage.

| Fixture | Exit | Score | Critical findings |
|---|---|---|---|
| clean | 0 | 100/100 | 0 |
| injected | 1 | 79/100 | 2 |
| hidden | 0 | 93/100 | 0 |

The injected example fails despite exceeding the numeric threshold: critical findings
are disqualifying. The hidden-character example passes with a high-severity warning.
These instruction-only fixtures have no supported install commands to extract; that
coverage limit is expected and never authorizes execution.

A repaired copy can lose its critical findings, but that does not establish package
identity, review referenced code, or authorize an installation.

## What to say after the exercise

- Scan: inspect supplied content for risk signals.
- Assess: evaluate an exact supported install action under protected policy.
- Enforce: a separate gate validates current matching permission before dispatch.

This participant exercise demonstrates scanning. It does not deploy an execution
gate, create a sandbox or automatically scan every action your agent takes.
