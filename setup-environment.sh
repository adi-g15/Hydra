#!/bin/bash
WhereAmI="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

case "$OSTYPE" in
  darwin*)  OS=0 ;;
  linux*)   OS=1 ;;
  *)        OS=2 ;;
esac

if [ $OS -eq 2 ]; then
    echo "Please use macOS or Ubuntu/Debain!"
fi
mkdir Hydra bin > /dev/null 2>&1
if [ $OS -eq 0 ]; then
    which -s brew
    if [[ $? != 0 ]] ; then
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" > /dev/null & while [ "$(ps a | awk '{print $1}' | grep $!)" ] ; do for X in '-' '/' '|' '\'; do echo -en "Installing Homebrew... $X "; sleep 0.1; done; done
    else
        brew update > /dev/null & while [ "$(ps a | awk '{print $1}' | grep $!)" ] ; do for X in '-' '/' '|' '\'; do echo -en "Updating Homebrew... $X "; sleep 0.1; done; done
    fi
    which -s docker
    if [[ $? != 0 ]] ; then
        brew install docker > /dev/null & while [ "$(ps a | awk '{print $1}' | grep $!)" ] ; do for X in '-' '/' '|' '\'; do echo -en "Installing Docker... $X "; sleep 0.1; done; done
    fi
    open -g -a Docker.app || exit
    docker system info > /dev/null & while [ "$(ps a | awk '{print $1}' | grep $!)" ] ; do for X in '-' '/' '|' '\'; do echo -en "Starting Docker... $X "; sleep 0.1; done; done
    if docker images | grep -q 'hbm'; then
		echo "HBM Image already exists...";
    else
        docker pull firelscar/hbm:latest > /dev/null & while [ "$(ps a | awk '{print $1}' | grep $!)" ] ; do for X in '-' '/' '|' '\'; do echo -en "Pulling HBM Image... $X "; sleep 0.1; done; done
    fi
    if docker ps -a | grep -q 'hbm'; then
		echo "Container already exists...";
    else
        docker run -d -v $WhereAmI:/home/HydraOS/ --name HBM firelscar/hbm:latest tail -f /dev/null > /dev/null & while [ "$(ps a | awk '{print $1}' | grep $!)" ] ; do for X in '-' '/' '|' '\'; do echo -en "Creating HBM Container... $X "; sleep 0.1; done; done
    fi
    echo "Checking macOS dependencies...";
    which -s mtools
    if [[ $? != 0 ]] ; then
        brew install mtools > /dev/null & while [ "$(ps a | awk '{print $1}' | grep $!)" ] ; do for X in '-' '/' '|' '\'; do echo -en "Installing mtools... $X "; sleep 0.1; done; done
    fi
    which -s qemu-system-x86_64
    if [[ $? != 0 ]] ; then
        brew install qemu > /dev/null & while [ "$(ps a | awk '{print $1}' | grep $!)" ] ; do for X in '-' '/' '|' '\'; do echo -en "Installing qemu... $X "; sleep 0.1; done; done
    fi
    echo -e "OS=macOS" > hbm
    echo "Done!";
    echo "Build and run with the 'make' command"
    exit
fi
if [ "$(uname -s)" = "Linux" ]; then
	KERNEL=$(uname -r)
	if [ -f /etc/debian_version ]; then
		if [ "$(awk -F= '/DISTRIB_ID/ {print $2}' /etc/lsb-release > /dev/null 2>&1)" = "Ubuntu" ]; then
			DIST="Ubuntu"
		else
			DIST="Debian"
		fi
	elif [ -f /etc/arch-release ]; then
		DIST="Arch"
        echo "Arch Linux is currently not available for building Hydra."
	fi
fi
if [ $DIST == "Ubuntu" ] || [ $DIST == "Debian" ]; then
    echo "Checking for $DIST dependencies...";
    apt update > /dev/null 2>&1
	which -a sudo > /dev/null 2>&1
    if [[ $? != 0 ]] ; then
        apt install sudo -y > /dev/null & while [ "$(ps a | awk '{print $1}' | grep $!)" ] ; do for X in '-' '/' '|' '\'; do echo -en "Installing sudo... $X "; sleep 0.1; done; done
    fi
	sudo apt update > /dev/null 2>&1
	which -a make > /dev/null 2>&1
    if [[ $? != 0 ]] ; then
        sudo apt install make -y > /dev/null & while [ "$(ps a | awk '{print $1}' | grep $!)" ] ; do for X in '-' '/' '|' '\'; do echo -en "Installing make... $X "; sleep 0.1; done; done
    fi
	which -a gcc > /dev/null 2>&1
    if [[ $? != 0 ]] ; then
        sudo apt install build-essential -y > /dev/null & while [ "$(ps a | awk '{print $1}' | grep $!)" ] ; do for X in '-' '/' '|' '\'; do echo -en "Installing build-essential... $X "; sleep 0.1; done; done
    fi
	which -a nasm > /dev/null 2>&1
    if [[ $? != 0 ]] ; then
        sudo apt install nasm -y > /dev/null & while [ "$(ps a | awk '{print $1}' | grep $!)" ] ; do for X in '-' '/' '|' '\'; do echo -en "Installing nasm... $X "; sleep 0.1; done; done
    fi
	which -a mtools > /dev/null 2>&1
    if [[ $? != 0 ]] ; then
        sudo apt install mtools -y > /dev/null & while [ "$(ps a | awk '{print $1}' | grep $!)" ] ; do for X in '-' '/' '|' '\'; do echo -en "Installing mtools... $X "; sleep 0.1; done; done
    fi
	which -a qemu-system-x86_64 > /dev/null 2>&1
    if [[ $? != 0 ]] ; then
            sudo apt install qemu-system -y > /dev/null & while [ "$(ps a | awk '{print $1}' | grep $!)" ] ; do for X in '-' '/' '|' '\'; do echo -en "Installing qemu-system... $X "; sleep 0.1; done; done
            sudo apt install qemu-system -y > /dev/null 2>&1
    fi
    echo -e "OS=Debian" > hbm
    echo "Done!";
    echo "Build and run with the 'make' command"
    exit

elif [ $DIST == "Arch" ]; then
    echo "Checking for $DIST dependencies...";
    # Not checking for sudo
    sudo pacman -Sy --needed base-devel nasm mtools qemu
    echo -e "OS=Arch" > hbm
    echo "Done!";
    echo "Build and run with the 'make' command"
    exit
fi
