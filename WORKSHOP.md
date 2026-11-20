# Inspect, scan, repair — the laptop challenge

You are reviewing a scholarship assistant for your school club. Its real job is to
summarize **public** eligibility requirements, deadlines and source links. Work in
pairs; switch who types halfway through.

Complete installation in [README.md](README.md) first. All commands below are run
from the repository root. On macOS/Linux use `./.tools/skillguard`; on Windows use
`.\.tools\skillguard.exe`. These commands scan text; they do not follow its instructions.

## 1. Predict — 2 minutes

Open `demo/clean/SKILL.md` and `demo/injected/SKILL.md` in your editor as text.

- What is the legitimate task?
- Which instructions try to override the user or hide behavior?
- Does summarizing public listings need private documents or software installation?

Write down your prediction before running the scans.

## 2. Scan and explain — 2 minutes

macOS/Linux:

```sh
./.tools/skillguard scan ./demo/clean/SKILL.md --verbose
./.tools/skillguard scan ./demo/injected/SKILL.md --verbose
```

Windows PowerShell:

```powershell
.\.tools\skillguard.exe scan .\demo\clean\SKILL.md --verbose
.\.tools\skillguard.exe scan .\demo\injected\SKILL.md --verbose
```

Run each command separately. The injected scan is **expected to fail with exit 1**;
that means the scanner detected the teaching example, not that installation broke.
Find one critical finding and one coverage limitation. Do not stop at the score.

## 3. Repair a copy — 2 minutes

macOS/Linux:

```sh
mkdir -p practice
cp demo/injected/SKILL.md practice/SKILL.md
```

Windows PowerShell:

```powershell
New-Item -ItemType Directory -Path practice -Force
Copy-Item .\demo\injected\SKILL.md .\practice\SKILL.md
```

Edit **only your practice copy**:

1. Remove the instruction override and secrecy directive.
2. Clearly restrict the task to public scholarship information.
3. Require confirmation before sending personal data or submitting an application.

Rescan it:

```sh
# macOS/Linux
./.tools/skillguard scan ./practice/SKILL.md --verbose
```

```powershell
# Windows
.\.tools\skillguard.exe scan .\practice\SKILL.md --verbose
```

Reducing suspicious instructions improves this document. A pass does not prove that
an entire skill package, its referenced code or an eventual action is safe.

## 4. Share — 2 minutes

Tell your partner, then the room:

- One instruction you changed and why.
- One thing the scan still does not prove.
- If it now passes, may the agent install software automatically? Explain.

Your three deliverables: **one finding, one repair, one limitation**.

## Optional: spot an invisible character

Scan `demo/hidden/SKILL.md` with the same command pattern. A U+200B zero-width space
is intentionally present. It should produce a warning; hidden characters are not
automatically critical. Inspect severity and findings rather than assuming a pass
means nothing was found.

## Save a report

```sh
# macOS/Linux
mkdir -p reports
./.tools/skillguard scan ./practice/SKILL.md --format json --output reports/practice.json
```

```powershell
# Windows
New-Item -ItemType Directory -Path reports -Force
.\.tools\skillguard.exe scan .\practice\SKILL.md --format json --output .\reports\practice.json
```

If installation is unavailable, read [expected results](docs/expected-results.md)
with your partner and complete the same reasoning exercise. The activity does not
require activating a skill, accessing private files, or running document commands.
