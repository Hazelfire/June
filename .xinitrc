[[ -f ~/.Xresources ]] && xrdb -I$HOME ~/.Xresources
feh --randomize --bg-fill ~/Pictures/wallpaper.jpg
blueman-applet &
nm-applet &
exec i3 
