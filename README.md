# DesktopExperience

[简体中文](#好桌面)

DesktopExperience is a glue project that aims to fix various problems during using Linux desktops.

This project requires `fish` shell.

Provided scripts:

bin/activate_tencent.fish [QQ|WeChat] : Use `get_notifier`, and recognize instance by several idenifiers, then simulate a click event to wake the application.

bin/fcitx5-switch : Notify fcitx5 to switch layout by `fcitx5-remote`, which avoids fcitx5 & GNOME 's shortcut triggering issue under Wayland. (Requires setting shortcut in GNOME Control Center)

bin/get_notifier : Get all registered tray icons through scanning D-Bus service.

bin/launch_*.fish : Wrappers for specific apps, automatically call `activate_tencent.fish` when detecting running instances, rather than launch a new instance.

budgie/bin/screenshot : Provides better screenshot workflow for Budgie Wayland.

# 好桌面

好桌面是一个用于为 Linux 下桌面使用过程中遇到的各种问题进行修补的胶水项目。

本项目同时需要 `fish` Shell。

脚本: 

bin/activate_tencent.fish [QQ|WeChat] : 通过 `get_notifier` 并根据软件特征识别对应实例，然后模拟点击事件以唤醒应用

bin/fcitx5-switch : 通过 `fcitx5-remote` 通知fcitx5切换输入法，避免了在GNOME下运行的Fcitx5(Wayland)会与系统快捷键冲突或同时触发的问题。（需要在GNOME设置中添加该脚本的快捷键）

bin/get_notifier : 通过扫描D-Bus托盘获取所有注册的托盘图标。

bin/launch_*.fish : 对特定应用的包装，可以在识别到有运行实例时自动调用 `activate_tencent.fish` 唤起，而不是启动新实例。

budgie/bin/screenshot : 为 Budgie Wayland 提供更好的截图工作流。