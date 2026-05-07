#!/bin/fish

set has_running_qq (ps aux | grep [/]opt/QQ/qq)

set cwd (dirname (status filename))

if ! test "$has_running_qq" = ""
    echo 'Request QQ Wake'
    exec $cwd/activate_tencent.fish QQ
else
    # 如果有参数传入，传递给 QQ
    if set -q argv[1]
        exec /opt/QQ/qq $argv
    else
        exec /opt/QQ/qq
    end
end
