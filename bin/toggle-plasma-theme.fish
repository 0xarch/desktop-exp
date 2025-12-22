#!/bin/fish

if plasma-apply-colorscheme -l | grep 当前 | grep -i Light
    plasma-apply-lookandfeel -a custom.material-reset.dark
else
    plasma-apply-lookandfeel -a custom.material-reset.light
end
