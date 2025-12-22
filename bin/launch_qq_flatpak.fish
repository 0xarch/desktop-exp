#!/bin/fish

set has_running_qq (flatpak ps --columns=application | grep QQ)

if ! test "$has_running_qq" = ""
    echo 'Request QQ Wake'
    exec $EXPERIENCE_DIR/bin/activate_tencent.fish QQ
else
    # 如果有参数传入，传递给 Flatpak
    if set -q argv[1]
        exec flatpak run --branch=stable --arch=x86_64 --command=qq --file-forwarding com.qq.QQ $argv
    else
        exec flatpak run --branch=stable --arch=x86_64 --command=qq com.qq.QQ
    end
end
