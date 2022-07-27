sleep 0.1
dly=0.1
sleep $dly
urxvtc --title pft --hold -e pfetch & disown
sleep $dly
urxvtc --title pckc --hold -e peaclock disown
sleep $dly
feh --title lavand --zoom fill --scale-down ~/.feh_pic.jpg & disown
sleep $dly
urxvtc --title main & disown
sleep $dly
urxvtc --title htp --hold -e htop & disown
sleep $dly
urxvtc --title nwsb --hold -e newsboat & disown
