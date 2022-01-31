#sudo apt install -y update-manager-core
sudo apt-get update && sudo apt-get -y upgrade
sudo do-release-upgrade

#install required packages
packages=`cat $HOME/Scripts/linux/ubuntu/packages.ubuntu.lst | tr "\n" " "`
echo "Installing Pakages - $packages"

sudo apt-get install -y $packages

sudo apt autoremove
