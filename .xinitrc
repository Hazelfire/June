[[ -f ~/.Xresources ]] && xrdb -I$HOME ~/.Xresources.dark
feh --randomize --bg-fill ~/Pictures/Wallpapers/stock-photo*989.jpg
blueman-applet &
nm-applet &
exec i3 
