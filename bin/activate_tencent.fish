#!/bin/fish
# activate_tencent.fish -
#       Something hacks launcher that fixed some tencent wares providing different clicking
#       behaviors for Windows (Wake present instance, nor launch) and Linux (Always
#       simply launch new instance).

# This script is not designed to simply use alone. You should use launch_qq.fish/launch_wechat.fish/launch_qq_flatpak.fish/launch_wechat_flatpak.fish .
# Replace Exec in .desktop file with these scripts. They handle detections automatically.

# This script is part of 0xarch's DesktopExperience project that aims to 
# improve the experience of linux desktop users.

# Confirmed working environment:
#   * KDE Wayland
#   * GNOME Wayland (requires manual setup, see below)
#   * Hyprland + Waybar
#   * Umbriel + Noctalia

# This scripts only works with the following way you installed ten-cent-wares:
# Official native package that puts garbage in /opt
#   (Most user. Officially they packed them to .deb and .rpm)
# Flatpak
#   (Recommended for managing ten-cent-wares)
# AppImage
#   (Only for QQ. And it's experimental in a very HACKY way, you also needs to do manual setup)

# AppImage Support Status:
#   They are hard to locate (as user may rename it) and squashfs is so squa-shy
#   Experimental Support For QQ:
#     1. You need a firejail and allow dbus-talk with tray service in linuxqq.profile to use this
#     2. You need to set DE_QQ_PATH to point to your QQ.AppImage, it has to be readable for this script, and launch_qq.AppImage

# REQUIRED EXECUTBALES:
# fish >= 3.7.0
# dbus-send (This is part of dbus core package. You don't need to install twice.)
# cat awk grep sed xargs

# KNOWN LIMITS:
#   * Only the first existing instance will be waken. We can't infer which instance you want if you have multiples. If you want that use your AI assistant.
#   * WeChat AppImage is currently not supported.
#   * May not work if your fish is built with weird options.

# GNOME: This script requires you installed & enabled "AppIndicator & KStatusNotifierItem Support" or other extension providing same functionality.
# as GNOME developers dropped tray support with the whole dbus tray service. shit-OME

set ACTIVE_TYPE $argv[1]

set cwd (status dirname)

if test -z "$ACTIVE_TYPE"
    echo "Usage: ./activate_tencent.fish [QQ|WeChat]"
    exit 1
end

# Splited out to achieve better control of different WM impl. Compatible for KDE,GNOME and Hyprland. (Also part of DesktopExperience project)
set TRAYS ($cwd/get_notifiers | string match -rv '^$')

if ! string length $TRAYS
    echo "Cannot get notifier items. Check your dbus service. If get_notifiers not found, re-clone the whole repository."
    exit 2
end

for tray in $TRAYS
    set proc_id (dbus-send --session --type=method_call --print-reply=literal --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.GetConnectionUnixProcessID string:$tray | awk '{print $2}')
    set cmdline (string split0 -- (cat /proc/"$proc_id"/cmdline))

    echo ":" $proc_id $cmdline

    # Firejail exposes tray through xdg-dbus-proxy so we have to
    # locate it's parent.

    switch $ACTIVE_TYPE
        case QQ
            # 1. native install 2. AppImage 3. Flatpak
            if string match -ie /opt/QQ/qq "$cmdline" || firejail --list | grep "$DE_QQ_PATH" | grep (ps -p "$proc_id" -o ppid= | xargs) || grep "com.qq.QQ" /proc/"$proc_id"/cgroup
                dbus-send --session --type=method_call --dest=$tray /StatusNotifierItem org.kde.StatusNotifierItem.Activate int32:0 int32:0
                exit 0
            end
        case WeChat
            # 1. native install 2. Flatpak
            if string match -ie /opt/wechat/wechat "$cmdline" || grep "com.tencent.WeChat" /proc/"$proc_id"/cgroup
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
