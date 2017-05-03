layout: post
title: Express Setup Development Environment with Archlinux
date: 2016-09-15 00:14:36
categories:
tags:
---

I tried install ubuntu in VirtualBox on my notebook. It's not smooth enough as a productivity environment. So I turn to use ArchLinux. It's a lightweight Linux Distribution which has no unnecessary additions unless you want.
It's perfect one if your want to setup a linux development environment on old machine.
Here I write down my notes on how to Setup Archlinux development environment in VirtualBox.

<!--more-->
## Archlinux

### Install Arch Linux as VirtualBox Guest OS

#### Create New Virtual Machine

- Download Arch Linux ISO Live CD

- Create VirtualBox Disk Image (VDI) with desired settings.

- Load the Arch Linux ISO as a CD/DVD image and select the “Boot Arch” option when the live CD boots.


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

1. taobao npmjs.org repo

* use cnpm

```bash
    npm install -g cnpm --registry=https://registry.npm.taobao.org
```

* npm alias

```bash
alias cnpm="npm --registry=https://registry.npm.taobao.org \
--cache=$HOME/.npm/.cache/cnpm \
--disturl=https://npm.taobao.org/dist \
--userconfig=$HOME/.cnpmrc"
```

Or alias it in .bashrc or .zshrc

```bash
$ echo '\n#alias for cnpm\nalias cnpm="npm --registry=https://registry.npm.taobao.org \
--cache=$HOME/.npm/.cache/cnpm \
--disturl=https://npm.taobao.org/dist \
--userconfig=$HOME/.cnpmrc"' >> ~/.zshrc && source ~/.zshrc
```

* use

从 registry.npm.taobao.org 安装所有模块. 当安装的时候发现安装的模块还没有同步过来, 淘宝 NPM 会自动在后台进行同步, 并且会让你从官方 NPM registry.npmjs.org 进行安装. 下次你再安装这个模块的时候, 就会直接从 淘宝 NPM 安装了.
```bash
$ cnpm install [name]
```

同步模块
直接通过 sync 命令马上同步一个模块, 只有 cnpm 命令行才有此功能:
```bash
$ cnpm sync connect
```

当然, 你可以直接通过 web 方式来同步: /sync/connect
```bash
$ open https://npm.taobao.org/sync/connect
```

其它命令
支持 npm 除了 publish 之外的所有命令, 如:

