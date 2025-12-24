#!/bin/fish
# activate_tencent.fish

set ACTIVE_TYPE $argv[1]

if test -z "$ACTIVE_TYPE"
    echo "Usage: ./activate_tencent.fish [QQ|WeChat]"
    exit 1
end

set TRAYS ($EXPERIENCE_DIR/bin/get_notifiers)

# Title,IconName,Id均为空的是QQ，Title=wechat & IconName='' & Id=wechat的是微信
for tray in $TRAYS
	# if qdbus6 $tray 2>/dev/null | grep "/org/ayatana" 1>/dev/null
	# 	echo "$tray is a Ayatana indicator"
	# 	continue
	# end
    # set title (qdbus6 $tray /StatusNotifierItem org.freedesktop.DBus.Properties.Get org.kde.StatusNotifierItem Title)
    # echo $title
    # set iconname (qdbus6 $tray /StatusNotifierItem org.freedesktop.DBus.Properties.Get org.kde.StatusNotifierItem IconName)
    # echo $iconname
    # set id (qdbus6 $tray /StatusNotifierItem org.freedesktop.DBus.Properties.Get org.kde.StatusNotifierItem Id)
    # echo $id
    set cmdline (cat /proc/(qdbus6 org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.GetConnectionUnixProcessID $tray)/cmdline)

    # 使用 switch 判断 ACTIVE_TYPE
    switch $ACTIVE_TYPE
        case QQ
	    # 尝试直接通过cmdline识别
	    if test "$cmdline" = "/opt/QQ/qq"
                dbus-send --session --type=method_call --dest=$tray /StatusNotifierItem org.kde.StatusNotifierItem.Activate int32:0 int32:0
        	exit 0
            end
	    	
            # 检测QQ：Title、IconName、Id 都为空
            # if qdbus6 $tray /MenuBar com.canonical.dbusmenu.Version
            #     echo "Skip $tray: QQ should have no /MenuBar"
            #     continue
    	    # end
            # if test -z "$title" -a -z "$iconname" -a -z "$id"
            #     echo "Try to activate QQ $tray"
            #     dbus-send --session --type=method_call --dest=$tray /StatusNotifierItem org.kde.StatusNotifierItem.Activate int32:0 int32:0
            #     exit 0
            # end
        case WeChat
            # 尝试直接通过cmdline识别
            if test "$cmdline" = "/opt/wechat/wechat"
                dbus-send --session --type=method_call --dest=$tray /StatusNotifierItem org.kde.StatusNotifierItem.Activate int32:0 int32:0
                exit 0
            end
            
            # 检测微信：Title='wechat'，IconName为空，Id='wechat'
            # if test "$title" = "wechat" -a -z "$iconname" -a "$id" = "wechat"
            #     echo "Try to activate Wecaht"
            #     dbus-send --session --type=method_call --dest=$tray /StatusNotifierItem org.kde.StatusNotifierItem.Activate int32:0 int32:0
            #     exit 0
            # end

        case '*'
            echo "Error: Unknown application type '$ACTIVE_TYPE'"
            exit 1
    end
end

echo "Cannot find running application: $ACTIVE_TYPE"
exit 1
