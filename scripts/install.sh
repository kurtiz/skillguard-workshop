#!/bin/sh
# Installs the repository-pinned release locally. No sudo, PATH edits or quarantine changes.
set -eu
fail() { printf 'Install failed: %s\n' "$*" >&2; exit 1; }
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
version=$(cat "$root/release/version.txt")
printf '%s\n' "$version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$' || fail 'Invalid pinned version.'
archive_source=
if [ "$#" -gt 0 ]; then
    [ "$#" -eq 2 ] && [ "$1" = '--archive' ] || fail 'Usage: sh scripts/install.sh [--archive /path/to/pinned.tar.gz]'
    archive_source=$2
fi
case $(uname -s) in Darwin) os=darwin ;; Linux) os=linux ;; *) fail 'Use scripts/install.ps1 on Windows.' ;; esac
case $(uname -m) in arm64|aarch64) arch=arm64 ;; x86_64|amd64) arch=amd64 ;; *) fail 'Supported architectures: amd64 and arm64.' ;; esac
asset="skillguard_${version}_${os}_${arch}.tar.gz"
expected=$(awk -v name="$asset" '$2 == name {value=$1; count++} END {if(count!=1) exit 1; print value}' "$root/release/checksums.txt") || fail 'Missing or duplicate release checksum.'
printf '%s\n' "$expected" | grep -Eq '^[a-f0-9]{64}$' || fail 'Invalid release checksum.'
for tool in tar mktemp; do command -v "$tool" >/dev/null 2>&1 || fail "Missing required tool: $tool"; done
[ ! -L "$root/.tools" ] || fail '.tools must not be a symbolic link.'
mkdir -p "$root/.tools"
[ ! -L "$root/.tools/skillguard" ] || fail 'The install destination must not be a symbolic link.'
work=$(mktemp -d "$root/.tools/download.XXXXXX")
trap 'rm -rf "$work"' EXIT HUP INT TERM
archive="$work/$asset"
if [ -n "$archive_source" ]; then
    cp "$archive_source" "$archive"
else
    command -v curl >/dev/null 2>&1 || fail 'curl is required for downloading; offline --archive is also supported.'
    curl --fail --location --proto '=https' --proto-redir '=https' --tlsv1.2 \
        --connect-timeout 15 --max-time 120 --retry 2 --max-filesize 67108864 \
        --output "$archive" "https://github.com/OSSAfrica/skillguard/releases/download/v${version}/${asset}"
fi
if command -v sha256sum >/dev/null 2>&1; then
    actual=$(sha256sum "$archive" | awk '{print $1}')
elif command -v shasum >/dev/null 2>&1; then
    actual=$(shasum -a 256 "$archive" | awk '{print $1}')
else
    fail 'A SHA-256 verifier is required (sha256sum on Linux, shasum on macOS).'
fi
[ "$actual" = "$expected" ] || fail 'SHA-256 mismatch. Nothing was installed; obtain the exact pinned release.'
printf 'Verified SHA-256 for %s\n' "$asset"
# Extract only the named binary, never all archive paths.
tar -xzf "$archive" -C "$work" skillguard
[ -f "$work/skillguard" ] && [ ! -L "$work/skillguard" ] || fail 'Archive did not contain a regular skillguard binary.'
chmod 755 "$work/skillguard"
mv -f "$work/skillguard" "$root/.tools/skillguard"
printf 'Installed locally: %s/.tools/skillguard\n' "$root"
if ! reported=$("$root/.tools/skillguard" --version); then
    printf 'The verified binary is installed but could not start. On macOS, see docs/macos.md.\n' >&2
    exit 1
fi
[ "$reported" = "skillguard version $version" ] || fail 'Installed executable reported an unexpected version.'
printf '%s\nNext: follow WORKSHOP.md from this repository root.\n' "$reported"
