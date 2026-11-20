# Guarding the Next Generation of AI

**Securing Skill Capabilities with SkillGuard** · Youth in AI Summit · Aaron Will Djaba

Clone, install SkillGuard, and review a fictional scholarship assistant. Work in pairs:
one person operates the terminal while the other explains what the findings mean.

```sh
git clone https://github.com/kurtiz/skillguard-workshop.git
cd skillguard-workshop
```

No Git? Use **Code → Download ZIP**, extract it, and open a terminal in the extracted
folder. This participant repository contains examples and installers, not an active
agent skill pack. Open the examples as text; do not activate their instructions.

## 1. Install SkillGuard

Review the script for your platform, then run it **from this repository root**.
It downloads the pinned official **v0.17.0** release, checks its SHA-256 against the
committed release checksums, and installs into `.tools` in this clone. It needs no
administrator access, Go, Python, coding-agent account or system PATH changes.

### macOS and Linux

```sh
sh scripts/install.sh
./.tools/skillguard --version
```

Supports Intel/AMD64 and ARM64. macOS includes the required tools; Linux needs `curl`,
`tar`, and `sha256sum` (or `shasum`). On macOS, if the verified binary is blocked,
follow [the Gatekeeper guide](docs/macos.md).

### Windows 10/11 — PowerShell

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1
.\.tools\skillguard.exe --version
```

Use PowerShell 5.1 or later with Windows' `tar.exe`; AMD64 and ARM64 are supported.
The execution-policy option applies only to this script process, not the system's
permanent policy. Organization-managed restrictions may still apply. See
[Microsoft's explanation](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_powershell_exe).

## 2. Start the exercise

Open [WORKSHOP.md](WORKSHOP.md). You will:

1. Inspect a skill before scanning it.
2. Compare it with a version containing an instruction override.
3. Repair a copy and explain the remaining limits.
4. Decide whether a passing scan grants permission to run an installer.

Budget **5 minutes for installation**, then **8 minutes for the pair challenge**.
The presenter will share a separate Funkwiz game invitation afterward.

## What is in this repo?

| Path | Purpose |
|---|---|
| `demo/clean/SKILL.md` | Ordinary scholarship-summary instructions |
| `demo/injected/SKILL.md` | Deliberately injected instructions, for inspection only |
| `demo/hidden/SKILL.md` | Optional invisible-character example |
| `scripts/install.sh` | macOS/Linux installer |
| `scripts/install.ps1` | Windows installer |
| `release/` | Exact engine version and published archive checksums |
| `docs/` | macOS help, expected results, installation details and facilitation |

`.tools/`, your `practice/` copies and `reports/` are ignored by Git. To uninstall
this workshop copy, remove `.tools`; other SkillGuard installations are unaffected.

**A scan is evidence, not execution permission.** A score or package listing does
not establish safety. Standard native plugins are advisory; execution enforcement
requires a separately configured gate and operator-provided isolation.

Project: [OSSAfrica/skillguard](https://github.com/OSSAfrica/skillguard).
