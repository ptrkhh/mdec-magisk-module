#!/system/bin/sh
# Runs in late_start service mode (boot completed, package manager up).
MODDIR=${0%/*}
PKG=com.samsung.android.mdecservice
BUNDLED="$MODDIR/system/app/MdecService/MdecService.apk"

# wait for boot to finish
until [ "$(getprop sys.boot_completed)" = 1 ]; do sleep 2; done
sleep 8

# already registered? nothing to do
if pm path "$PKG" >/dev/null 2>&1; then
    exit 0
fi

# Prefer the ROM's own (correctly platform-signed) apk; fall back to bundled.
APK=""
for d in /system/app /system/priv-app /system_ext/app /system_ext/priv-app \
         /product/app /product/priv-app /vendor/app; do
    if [ -f "$d/MdecService/MdecService.apk" ]; then
        APK="$d/MdecService/MdecService.apk"
        break
    fi
done
# wider glob in case the folder name differs
if [ -z "$APK" ]; then
    for f in /system/*/Mdec*/*.apk /product/*/Mdec*/*.apk /system_ext/*/Mdec*/*.apk; do
        [ -f "$f" ] && { APK="$f"; break; }
    done
fi
# last resort: bundled apk
[ -z "$APK" ] && [ -f "$BUNDLED" ] && APK="$BUNDLED"

[ -n "$APK" ] && pm install -g -r "$APK" >/dev/null 2>&1
