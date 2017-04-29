layout: post
title: Express Setup Development Environment
date: 2016-09-15 00:14:36
categories:
tags:
---

I tried install ubuntu in VirtualBox on my notebook. It's not smooth enough as a productivity tool. So I turn to use ArchLinux, a lightweight Linux release. Here I write down my notes on how to Setup Archlinux development environment in VirtualBox.

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


