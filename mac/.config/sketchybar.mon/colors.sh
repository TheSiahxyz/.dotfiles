#!/bin/bash

### Sonokai
# export BLACK=0xff181819       #181819
# export WHITE=0xffe2e2e3       #e2e2e3
# export RED=0xfffc5d7c         #fc5d7c
# export GREEN=0xff9ed072       #9ed072
# export BLUE=0xff76cce0        #76cce0
# export YELLOW=0xffe7c664      #e7c664
# export ORANGE=0xfff39660      #f39660
# export MAGENTA=0xffb39df3     #b39df3
# export GREY=0xff7f8490        #7f8490
# export BG0=0xff2c2e34         #2c2e34
# export BG1=0xff363944         #363944
# export BG2=0xff414550         #414550
# export TRANSPARENT=0x00000000 #000000

### Catppuccin
export ROSEWATER=0xfff4dbd6 #f4dbd6
export FLAMINGO=0xfff0c6c6  #f0c6c6
export PINK=0XFff5bde6      #f5bde6
export MAUVE=0Xffc6a0f6     #c6a0f6
export RED=0XFFed8796       #ed8796
export MAROON=0xffee99a0    #ee99a0
export PEACH=0Xfff5a97f     #f5a97f
export YELLOW=0xffeed49f    #eed49f
export GREEN=0Xffa6da95     #a6da95
export TEAL=0XFf8bd5ca      #8bd5ca
export SKY=0XFF91d7e3       #91d7e3
export SAPPHIRE=0xff7dc4e4  #7dc4e4
export BLUE=0XFf8aadf4      #8aadf4
export LAVENDER=0xffb7bdf8  #b7bdf8
export TEXT=0xffcad3f5      #cad3f5
export SUBTEXT1=0xffb8c0e0  #b8c0e0
export SUBTEXT0=0xffa5adcb  #a5adcb
export OVERLAY2=0xff939ab7  #939ab7
export OVERLAY1=0xff8087a2  #8087a2
export OVERLAY0=0xff6e738d  #6e738d
export SURFACE2=0xff5b6078  #5b6078
export SURFACE1=0xff494d64  #494d64
export SURFACE0=0xff363a4f  #363a4f
export BASE=0XFf24273a      #24273a
export MANTLE=0xff1e2030    #1e2030
export CRUST=0Xff181926     #181926

# Others
export MAGENTA=0xffc6a0f6 #c6a0f6
export ORANGE=0xfff5a97f  #f5a97f
export CYAN=0xff89DDFF    #89DDFF
export OSBLUE=0xff0259D1  #0259D1

# Base Colors
export BASE=0xff24273a        #24273a
export BASE_BLACK="181926"    #181926
export BASE_WHITE="eeeeee"    #eeeeee
export WHITE=0xffcad3f5       #cad3f5
export LIGHT_GREY=0xffa6accd  #a6accd
export GREY=0xff939ab7        #939ab7
export GREY_50=0x80676e95     #676e95
export DARK_GREY=0xff292d3e   #292d3e
export BLACK=0xff181926       #181926
export BG0=0xff1e1e2e         #1e1e2e
export BG1=0x603c3e4f         #3c3e4f
export BG2=0x60494d64         #494d64
export TRANSPARENT=0x00000000 #000000

O100=0xff # 100%
O75=0xbf  # 75%
O50=0x80  # 50%
O25=0x40  # 25%
O10=0x1a  # 10%

export BLACK_75="$O75""$BASE_BLACK"
export BLACK_50="$O50""$BASE_BLACK"
export BLACK_25="$O25""$BASE_BLACK"
export WHITE_75="$O75""$BASE_WHITE"
export WHITE_50="$O50""$BASE_WHITE"
export WHITE_25="$O25""$BASE_WHITE"
export WHITE_10="$O10""$BASE_WHITE"

# Text Colors
export TEXT=0xffcad3f5     #cad3f5
export SUBTEXT0=0xffb8c0e0 #b8c0e0
export SUBTEXT1=0xffa5adcb #a5adcb
export SURFACE0=0xff363a4f #363a4f
export SURFACE1=0xff494d64 #494d64
export SURFACE2=0xff5b6078 #5b6078
export OVERLAY0=0xff6e738d #6e738d
export OVERLAY1=0xff8087a2 #8087a2
export OVERLAY2=0xff939ab7 #939ab7

# General Bar Colors
export BAR_COLOR=$BG0
export BAR_BORDER_COLOR=$BG2
export BACKGROUND_1=$BG1
export BACKGROUND_2=$BG2
export CONTRAST=0xff34324a #34324a
export HIGHLIGHT=$TEAL
export ICON_COLOR=$WHITE # Color of all icons
export ICON_COLOR_INACTIVE=$GREY
export LABEL_COLOR=$WHITE # Color of all labels
export POPUP_BACKGROUND_COLOR=$BAR_COLOR
export POPUP_BORDER_COLOR=$WHITE
export SHADOW_COLOR=$BLACK
