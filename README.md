# Samsung CMC Magisk Module

Restores **"Call & text on other devices"** (Samsung Call & Message Continuity,
package `com.samsung.android.mdecservice`) on Samsung ROMs/ports where it was
debloated out of the package database.

## How it works
The APK is left in `/system/app` by many ports but never scanned (the system app
record was removed, so PMS ignores the file). A pure file overlay won't fix that —
the skip is keyed on the package record, not file presence. So `service.sh` runs
`pm install` post-boot if the package is missing.

It **prefers the ROM's own MdecService.apk** (searched across `/system`, `/system_ext`,
`/product`) because that copy is guaranteed to match the device's platform key. Only
if no on-ROM copy exists does it fall back to the **bundled** APK.

## Requirements
- Root (Magisk v20.4+)
- If the module falls back to the **bundled** APK, that APK must be **signed with the
  same platform key as the target device** (Samsung Cert), same One UI major version.
  If the key differs, replace `system/app/MdecService/MdecService.apk` with one pulled
  from that device's own stock firmware. (Not a concern when the ROM already ships its
  own copy — the common case — since the module uses that.)

## Which zip
- `mdec-cmc-full.zip` (~8 MB) — bundles the APK **and** searches the ROM. Use when the
  device may have MdecService.apk fully stripped. Falls back to bundled only if no
  on-ROM copy exists (bundled must then match the device platform key — see Requirements).
- `mdec-cmc-noapk.zip` (~2 KB) — `service.sh` only. Use when the ROM still ships
  MdecService.apk somewhere (the common debloat case); installs that native, key-matched
  copy. No-op if neither on-ROM nor bundled APK is found.

## Install
- Magisk app > Modules > Install from storage > pick a zip > reboot.
- Or direct (rooted shell): copy the folder to `/data/adb/modules/mdec_cmc/` and reboot.

## After install
Settings > Connected devices > **Call & text on other devices** (now visible).

## Files
- `module.prop` — module metadata
- `service.sh` — late_start installer; prefers ROM apk, falls back to bundled (idempotent)
- `system/app/MdecService/MdecService.apk` — bundled platform-signed CMC app (v6.2.00.12)
- `mdec-cmc-full.zip` — flashable, with bundled APK
- `mdec-cmc-noapk.zip` — flashable, ROM-only (no bundled APK)

## Notes
- Only `mdecservice` is needed; `mdeccommon` is bundled inside it.
- `MDEC` = Call & Message Continuity. Phone = Primary Device, tablet = Secondary.
