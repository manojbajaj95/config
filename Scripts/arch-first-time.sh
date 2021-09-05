# Reflector update mirrors
sudo pacman -Syu

#install required packages
packages=`cat $HOME/Scripts/packages.arch.core.lst | tr "\n" " "`
echo "Installing Pakages - $packages"

sudo pacman -S $packages
