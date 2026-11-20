# Installation details

These installers select official release v0.17.0 from `release/version.txt` and
`release/checksums.txt`. They support macOS, Linux and Windows on AMD64 and ARM64.
The checksum file was downloaded from that exact release, not generated from an
untrusted archive. Maintainers must review future version/checksum updates together.

Installers verify an archive before extracting the named binary or executing it.
A hash mismatch stops installation and preserves an existing workshop executable.
Temporary downloads are cleaned up. Installed files stay in this clone's `.tools`;
there is no package-manager install, global PATH edit or administrator operation.

Normal downloads use HTTPS to the official GitHub release. An offline option is
available when the presenter supplies the **exact** platform archive in advance:

```sh
sh scripts/install.sh --archive /path/to/skillguard_0.17.0_linux_amd64.tar.gz
```

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1 -Archive C:\Downloads\skillguard_0.17.0_windows_amd64.tar.gz
```

Offline archives undergo the same committed checksum check. The installer will not
substitute another version, skip verification or use an arbitrary mirror.

The scripts verify the installed version. If the binary is verified but the operating
system blocks startup, it remains installed for troubleshooting. For macOS see
[Gatekeeper help](macos.md). On a managed machine, follow the organization's controls.

The Windows download uses the platform's HTTPS stack and its redirect handling; both
installers require the final archive to match the pinned SHA-256. Network/proxy errors
are not scan results. The Windows script requires PowerShell 5.1+ and Windows `tar.exe`.
WSL uses the Linux installer and produces a Linux executable.

Optional current-session PATH shortcuts, after installation:

```sh
export PATH="$PWD/.tools:$PATH"
skillguard --version
```

```powershell
$env:Path = "$PWD\.tools;$env:Path"
skillguard --version
```

These affect only the current shell. The main exercise uses the explicit local path
to avoid accidentally scanning with a different global installation.
