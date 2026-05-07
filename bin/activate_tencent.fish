#!/bin/fish
# activate_tencent.fish -
#       Something hacks launcher that fixed some shitwares providing different clicking
#       behaviors for Windows (Wake present instance, nor launch) and Linux (Always
#       simply launch new instance).

# This scripts only works with the following way you installed shitwares:
# Official package that puts garbage in /opt
#   (Most user. Officially they packed them to .deb and .rpm. Arch works as they repack .deb)
# Flatpak
#   (Recommended for managing shitwares)

# REQUIRES EXECUTBALES:
# fish > 4.0.0
# dbus-send cat awk grep sed

set ACTIVE_TYPE $argv[1]

set cwd (status dirname)

if test -z "$ACTIVE_TYPE"
    echo "Usage: ./activate_tencent.fish [QQ|WeChat]"
    exit 1
end

set TRAYS ($cwd/get_notifiers)

for tray in $TRAYS
    set proc_id (dbus-send --session --type=method_call --print-reply=literal --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.GetConnectionUnixProcessID string:$tray | awk '{print $2}')
    set cmdline (cat /proc/"$proc_id"/cmdline)

    switch $ACTIVE_TYPE
        case QQ
            # Detect through cmdline or cgroup (flatpak) (performs better than simply matching title, icon, id)
            if test "$cmdline" = /opt/QQ/qq || grep "com.qq.QQ" /proc/"$proc_id"/cgroup
                # qdbus6 does not work with this method. Weird...?
                dbus-send --session --type=method_call --dest=$tray /StatusNotifierItem org.kde.StatusNotifierItem.Activate int32:0 int32:0
                exit 0
            end
        case WeChat
            if test "$cmdline" = /opt/wechat/wechat || grep "com.tencent.WeChat" /proc/"$proc_id"/cgroup
                dbus-send --session --type=method_call --dest=$tray /StatusNotifierItem org.kde.StatusNotifierItem.Activate int32:0 int32:0
                exit 0
            end
        case '*'
            echo "Error: Unknown application type '$ACTIVE_TYPE'"
            exit 3
    end
end

echo "Cannot find running application: $ACTIVE_TYPE"
exit 4
