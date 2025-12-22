# Desktop EXP

如果要使用本项目，需要先在用户配置文件中配置环境变量为本仓库的本地目录。

本项目同时需要 Fish Shell。

脚本：
activate_tencent.fish [QQ|WeChat] ：通过get_notifier并根据软件特征识别对应实例，然后模拟点击事件以唤醒应用

fcitx5-toggle-kb ：通过D-Bus通知Fcitx5切换输入法，避免了在GNOME下运行的Fcitx5(Wayland)会与系统快捷键冲突或同时触发的问题。（需要在GNOME设置中添加该脚本的快捷键）

get_notifier ：通过扫描D-Bus托盘获取所有注册的托盘图标

launch_*.fish ：对特定应用的包装，可以在识别到有运行实例时自动调用 activate_tencent.fish 唤起，而不是启动新实例。
