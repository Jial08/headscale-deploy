#!/bin/bash

# e 是命令 echo 的一个可选项，它用于激活特殊字符的解析器

# https://blog.csdn.net/fdipzone/article/details/9993961
# tput Color Capabilities:

# tput setab [0-7] – Set a background color using ANSI escape
# tput setb [0-7] – Set a background color
# tput setaf [0-7] – Set a foreground color using ANSI escape
# tput setf [0-7] – Set a foreground color

# Color Code for tput:

# 0 – Black
# 1 – Red
# 2 – Green
# 3 – Yellow
# 4 – Blue
# 5 – Magenta
# 6 – Cyan
# 7 – White

# tput Text Mode Capabilities:

# tput bold – Set bold mode
# tput dim – turn on half-bright mode
# tput smul – begin underline mode
# tput rmul – exit underline mode
# tput rev – Turn on reverse mode
# tput smso – Enter standout mode (bold on rxvt)
# tput rmso – Exit standout mode
# tput sgr0 – Turn off all attributes

## blue to echo
function blue() {
    echo -e "$(tput setaf 4)$1$(tput sgr0)"
}

## green to echo
function green() {
    echo -e "$(tput setaf 2)$1$(tput sgr0)"
}

## Error
function red() {
    echo -e "$(tput setaf 1)$1$(tput sgr0)"
}

## warning
function yellow() {
    echo -e "$(tput setaf 3)$1$(tput sgr0)"
}
