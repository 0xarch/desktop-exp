#!/bin/fish

set has_running_wc (flatpak ps --columns=application | grep WeChat)

if ! test "$has_running_wc" = ""
    echo 'Request WeChat Wake'
    exec $EXPERIENCE_DIR/bin/activate_tencent.fish WeChat
else
    # 如果有参数传入，传递给 Flatpak
    if set -q argv[1]
        exec flatpak run --branch=stable --arch=x86_64 --command=wechat --file-forwarding com.tencent.WeChat $argv
    else
        exec flatpak run --branch=stable --arch=x86_64 --command=wechat com.tencent.WeChat
    end
end
