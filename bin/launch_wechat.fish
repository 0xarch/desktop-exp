#!/bin/fish

set has_running_wc (ps aux | grep [/]opt/wechat/wechat)

set cwd (dirname (status filename))

if ! test "$has_running_wc" = ""
    echo 'Request WeChat Wake'
    exec $cwd/activate_tencent.fish WeChat
else
    # 如果有参数传入，传递给 WC
    if set -q argv[1]
        exec /opt/wechat/wechat $argv
    else
        exec /opt/wechat/wechat
    end
end
