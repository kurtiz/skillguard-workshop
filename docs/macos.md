# macOS: opening the verified workshop binary

The installer checks the official release archive's SHA-256 before extracting or
running anything. It never changes Gatekeeper or removes quarantine automatically.
A checksum verifies the selected archive's identity; it is not Apple notarization
and does not prove that software is harmless.

## Recommended approval flow

If macOS blocks `./.tools/skillguard --version` with an unidentified-developer or
unnotarized-software warning, first confirm that the installer printed its successful
checksum verification. Then use **System Settings → Privacy & Security → Open Anyway**
for the blocked binary, if that option is available, and retry the command.

Apple documents this per-app override in [Safely open apps on your Mac](https://support.apple.com/en-us/102445).
Managed Macs may require an administrator's approval.

## Terminal option for the one verified file

From the workshop repository root, inspect whether that binary has a quarantine
attribute:

```sh
xattr -p com.apple.quarantine ./.tools/skillguard
```

If the attribute exists, you have verified the release through the installer and
you choose to trust this exact binary, remove **only that file's** quarantine:

```sh
xattr -d com.apple.quarantine ./.tools/skillguard
./.tools/skillguard --version
```

This removes a downloaded-file attribute; it does not get the program approved by
Apple. It does not notarize or sign it. If `xattr` reports that no such attribute exists,
skip removal: the failure has another cause.

Keep Gatekeeper enabled. Do not remove quarantine recursively from the clone or your
Downloads folder. No `sudo` is needed for this user-owned workshop installation.
Do not use this procedure for an explicit malware, revoked-signature or tampering alert.

For the meaning of `xattr -p` and `xattr -d`, run `man xattr` on your Mac.
