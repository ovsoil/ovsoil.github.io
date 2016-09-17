layout: post
title: express setup development environment
date: 2016-09-15 00:14:36
categories:
tags:
---


## Archlinux

### Install Arch Linux as VirtualBox Guest OS

When I was an intern at Sandia National Laboratories I was introduced to the concept of using virtual machines to sandbox my projects. I have found this to be very helpful for many software experiments and development environments. I even use virtual machines to run my day-to-day Linux install. Here I give my notes on how to use Virtual Box to run an Arch Linux guest install on Mac OS X. Once a base install is complete it’s easy to make snapshots and spin up and destroy clones from the base install as needed.

#### Create New Virtual Machine

- Download Arch Linux ISO Live CD

- Create VirtualBox Disk Image (VDI) with desired settings.

- Load the Arch Linux ISO as a CD/DVD image and select the “Boot Arch” option when the live CD boots.

<!--more-->

#### Install and System configuration

```bash
    # Partition the drive(s)
    fdisk /dev/sda
    # Format Partitions
    mkfs.ext4 /dev/sda1
    mkswap /dev/sda2
    # Mount Partitions
    mount /dev/sda1 /mnt
    swapon /dev/sda2
    # Install Base System
    pacstrap /mnt base base-devel linux
    # Generate File System Table
    genfstab -p /mnt >> /mnt/etc/fstab
    #Change Root Directory
    arch-chroot /mnt
    # Configure language
    echo LANG="en_US.UTF-8" >> /etc/locale.conf
    echo LC_COLLATE="C" >> /etc/locale.conf
    echo LC_TIME="en_US.UTF-8" >> /etc/locale.conf
    echo "en_US.UTF-8 UTF-8" >>/etc/locale.gen
    locale-gen
    ln -s /usr/share/zoneinfo/America/New_York /etc/localtime
    hwclock --systohc --utc
    # Generate Ram Disk
    mkinitcpio -p linux
    # Install and Configure Bootloader
    pacman -S syslinux gdisk
    syslinux-install_update -iam
    # Exit CHROOT, Unmount Drives and Reboot
    exit
    umount -R /mnt
    reboot
    ```

#### Post Install
The following isn’t really intended to be executed as a script.
    ```bash
    # Setup Network
    systemctl start dhcpcd
    systemctl enable dhcpcd
    
    # Virtual Box Guest Utilities
    # https://wiki.archlinux.org/index.php/VirtualBox#Arch_Linux_as_a_guest_in_a_Virtual_Machine
    pacman -S virtualbox-guest-utils --noconfirm
    modprobe -a vboxguest vboxsf vboxvideo
    echo vboxguest >> /etc/modules-load.d/virtualbox.conf
    echo vboxsf >> /etc/modules-load.d/virtualbox.conf
    echo vboxvideo >> /etc/modules-load.d/virtualbox.conf
    groupadd vboxsf
    systemctl enable vboxservice
    systemctl start vboxservice
    
    # X Windows System
    pacman -S xorg-server xorg-server-utils xorg-xinit xterm ttf-dejavu --noconfirm
    pacman -S awesome
    # User Configuration
    pacman -S sudo --noconfirm
    # use visudo to add  under "User privilege specification" before
    # using sudo as
    # Replace user_name with desired user name.
    useradd -m -g users -G optical,power,storage,vboxsf -s /bin/bash user_name
    chown root.vboxsf /media
    # Set  password using "# passwd "
    # Set root password using "# passwd"
    # Update Packages and System
    pacman -Syy
    pacman -Syu
    ```

#### Per User Config
    ```bash
    # Configuration for users other than root.
    echo /usr/bin/VBoxClient-all >> ~/.xinitrc
    echo "exec awesome" >> ~/.xinitrc
    ln -s /media/sf_share_name/* ~/share_name
    ```

#### develop environment


## Ubuntu

### Install and system configuration

#### Install

#### change apt sourcelist
    ```
    deb http://mirrors.163.com/ubuntu/ xenial main restricted universe multiverse
    deb http://mirrors.163.com/ubuntu/ xenial-security main restricted universe multiverse
    deb http://mirrors.163.com/ubuntu/ xenial-updates main restricted universe multiverse
    deb http://mirrors.163.com/ubuntu/ xenial-proposed main restricted universe multiverse
    deb http://mirrors.163.com/ubuntu/ xenial-backports main restricted universe multiverse
    deb-src http://mirrors.163.com/ubuntu/ xenial main restricted universe multiverse
    deb-src http://mirrors.163.com/ubuntu/ xenial-security main restricted universe multiverse
    deb-src http://mirrors.163.com/ubuntu/ xenial-updates main restricted universe multiverse
    deb-src http://mirrors.163.com/ubuntu/ xenial-proposed main restricted universe multiverse
    deb-src http://mirrors.163.com/ubuntu/ xenial-backports main restricted universe multiverse
    ```
    ```bash
    sudo apt-get update
    sudo apt-get upgrade
    ```

### develop
    ```bash
    sudo apt-get install build-essential libssl-dev
    sudo apt-get install vim emacs git
    # java
    sudo add-apt-repository ppa:webupd8team/java
    sudo apt update
    sudo apt install oracle-java8-installer
    # python
    sudo apt-get install virtualenvwrapper
    # nodejs
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.7/install.sh | bash
    # npm
    sudo apt-get install npm
    # use cnpm instead of npm
    npm install -g cnpm --registry=https://registry.npm.taobao.org

    ```


## Mac OS


