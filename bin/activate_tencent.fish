#!/bin/fish
# activate_tencent.fish -
#       Something hacks launcher that fixed some tencent wares providing different clicking
#       behaviors for Windows (Wake present instance, nor launch) and Linux (Always
#       simply launch new instance).

# This script is not designed to simply use alone. You should use launch_qq.fish/launch_wechat.fish/launch_qq_flatpak.fish/launch_wechat_flatpak.fish .
# Replace Exec in .desktop file with these scripts. They handle detections automatically.

# This script is part of 0xarch's DesktopExperience project that aims to 
# improve the experience of linux desktop users.

# This script is confirmed working under Wayland but untested for X11.

# This script requires you installed & enabled "AppIndicator & KStatusNotifierItem Support" or other functionality-same extension in GNOME
# as GNOME developers dropped tray support even with the whole dbus tray service. shit st-OME

# This scripts only works with the following way you installed tencent wares:
# Official package that puts garbage in /opt
#   (Most user. Officially they packed them to .deb and .rpm. Arch works as they repack .deb)
# Flatpak
#   (Recommended for managing tencent wares)

# This script does not support AppImage. They are hard to locate (as user may rename it) and squashfs is so squa-shy

# REQUIRES EXECUTBALES:
# fish >= 3.7.0
# dbus-send (This is part of dbus core package. You don't need to install twice.)
# cat awk grep sed

set ACTIVE_TYPE $argv[1]

set cwd (status dirname)

if test -z "$ACTIVE_TYPE"
    echo "Usage: ./activate_tencent.fish [QQ|WeChat]"
    exit 1
end

# Splited out to achieve better control of different WM impl. Compatible for KDE,GNOME and Hyprland. (Also part of DesktopExperience project)
set TRAYS ($cwd/get_notifiers)

if ! string length $TRAYS
    echo "Cannot get notifier items. Check your dbus service. If get_notifiers not found, re-clone the whole repository."
    exit 2
end

for tray in $TRAYS
    set proc_id (dbus-send --session --type=method_call --print-reply=literal --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.GetConnectionUnixProcessID string:$tray | awk '{print $2}')
    set cmdline (string split0 -- (cat /proc/"$proc_id"/cmdline))

    # if application exited during script running or other things causing race-if, nothing needs. 
    # GUI users don't care whether a back script returns an error that is not displayed.

    switch $ACTIVE_TYPE
        case QQ
            # Detect through cmdline or cgroup (flatpak) (performs better than simply matching title, icon, id)
            if test "$cmdline" = /opt/QQ/qq || grep "com.qq.QQ" /proc/"$proc_id"/cgroup
                # for qq and wechat they are both a bit "modern" as they use KStatusNotifier, not canonical-menu, unity-menu, xembed or other thing. Simply works.
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
