# Reviewed workshop release pin

Engine: **SkillGuard v0.17.0**.

Source: https://github.com/OSSAfrica/skillguard/releases/tag/v0.17.0
Checksums: https://github.com/OSSAfrica/skillguard/releases/download/v0.17.0/checksums.txt

The committed checksum file is the exact official release asset retrieved while
preparing this workshop. It covers darwin/linux/windows on amd64/arm64. Installer
selection is fixed by `version.txt`; it does not resolve a floating latest version.

To update, review a new release and replace the version and all six checksums
together, run the installer tests and native platform CI, and recheck the exercise
results. Hash verification identifies the reviewed archive; it does not prove safety.
