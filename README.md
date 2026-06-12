# CSOps Bypass

Bypass jailbreak detection that uses `csops()` code signing flag queries (the "get-task-allow" check).

## How it works

Hooks the `csops()` and `csops_audittoken()` system call wrappers in every UIKit process. When an app queries its own code signing status, this tweak strips `CS_GET_TASK_ALLOW` and `CS_DEBUGGED` from the returned flags and ensures `CS_VALID` stays set.

## Build (GitHub Actions)

1. Create a GitHub repo and push this project.
2. Run the `Build CSOpsBypass` workflow from the Actions tab, **or** push a tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. Download the `.deb` from the workflow artifacts or the GitHub Release.

## Install

1. Copy the `.deb` to your Dopamine device (AirDrop / Filza / scp).
2. Open it with **Sileo** or **Zebra** and tap Install.
3. The device will respring automatically.

### Manual install (terminal)

```bash
sudo dpkg -i com.patch.csopsbypass_1.0.0_iphoneos-arm64.deb
sbreload
```

## Uninstall

Remove `CSOps Bypass` from Sileo/Zebra, or:

```bash
sudo dpkg -r com.patch.csopsbypass
sbreload
```

## Compatibility

- iPhone X (A11), iOS 16.7.15, Dopamine rootless
- Requires ElleKit or MobileSubstrate (Dopamine ships ElleKit)

## Notes

- The filter plist injects into **all UIKit processes**. To target specific apps only, edit `CSOpsBypass.plist` and replace `com.apple.UIKit` with the target app's bundle identifier.
- If detection also checks for jailbreak files, combine with an existing file-hiding tweak (Shadow, Hestia, vnodebypass).
