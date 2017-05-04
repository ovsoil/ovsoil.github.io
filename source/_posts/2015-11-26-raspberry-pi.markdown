---
layout: post
title: "Raspberry Pi"
date: 2015-11-26 15:39:11
comments: true
categories: 
---



![Raspberry-Pi-2](http://op9wke666.bkt.clouddn.com/Raspberry-Pi-2.jpeg-original)

`Raspberry Pi` 有如下接口：

* 电源输入：Micro usb接口的5V 1A 的输入电流。
* 2个USB接口：可以接鼠标和键盘等。
* HDMI接口：接HDMI接口的显示器，如果是DVI或VGA的，需要买转接线。
* 以太网接口：100M的以太网接口，插网线上网用的。
* 模拟信号音频和视频输出接口：可以接电视机，输出模拟信号，显示在电视机上。
* SD卡插口：插入SD卡，作存储用。

<!--more-->

## 连接树莓派

### ssh连接

如果没有HDMI显示器或者串口调试工具，我们也可以通过ssh连接`Raspberry Pi`。第一次启动`Raspberry Pi`，很难确定Pi的IP地址，但可以通过其它Linux平台(本文以ubuntu为例）的`dhcp-server`配置并知晓IP。

1. 安装
    `sudo apt-get install dhcp`
2. 配置：
    `sudo vim /etc/dhcp/dhcpd.conf`   
加入以下内容
```bash
    subnet 192.168.1.0 netmask 255.255.255.0 { 
    range 192.168.1.2 192.168.1.114; 
    default-lease-time 86400; 
    max-lease-time 259200; 
    option subnet-mask 255.255.255.0; 
    option broadcast-address 192.168.1.255; 
    option routers 192.168.1.2; 
    option domain-name-servers 192.168.1.2; 
    }
```
配置dhcp server的IP（与配置文件中指定的相同），并启动`dhcpd`.
``` bash
    sudo ifconfig eth0 192.168.1.2/24
    sudo dhcpd
```
3. 连上网线，启动Raspberry Pi即可在dhcp-server端查看Pi的IP：
```bash
    cat /var/lib/dhcpd/dhcpd.lease
    ssh pi@Pi'sIP
```
### 远程桌面
在Pi上安装xrdp，默认xrdp会随机启动
    `sudo apt-get install xrdp`
在其它Linux平台上安装rdesktop，一个远程桌面客户端：
    `sudo apt-get install rdesktop`

### 共享上网

使用一根网线连接Pi和电脑实现了Pi和电脑的互联，Pi却无法连接internet。

我使用iptables来让Fedora作路由器的功能，相当于Pi通过网线连接到了一台局域网的路由器一样。
 Fedora当路由器作用，同时作Nat功能，将Pi的地址转换为Fedora连接局域网的网卡的地址（我这里的网卡是无线网卡），因为局域网路由器和Pi不在一个网段。

打开Fedora的ip_forward功能，允许转发从Pi发来的和到达Pi的包，作路由器用:
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
在Fedora上面添加iptables，实现SNAT:
sudo iptables -t nat -A POSTROUTING -j SNAT \
	--to-source 192.168.1.100 --random
–random 选项让内核帮我们选源端口
192.168.1.100 是我连接路由器上网的那个网卡的ip地址，是个无线网卡,接口wlan0

在Pi内部检测网络联通：
ping www.baidu.com
如果没有配置域名服务器 需要配置域名解析服务器地址:

echo nameserver 8.8.8.8 | sudo tee /etc/resolv.conf

## 树莓派配置

### raspi-config
第一项 Expand Filesystem 扩展 SD 卡上可用的空间
### 网络和软件源


#### Let's start by customising the /etc/ifplugd/action.d/ifupdown script:


编辑 `/etc/ifplugd/action.d/ifupdown` :
```bash
#!/bin/sh 
set -e 
  
case "$2" in 
up) 
  /sbin/ifup $1 
  if [ "$1" == eth0 ]; then /sbin/ifdown wlan0 ; fi # This is a new bit 
  ;; 
down) 
  /sbin/ifdown $1 
  if [ "$1" == eth0 ]; then /sbin/ifup wlan0 ; fi # Another new bit 
  ;; 
esac
```



### Samba
#### samba安装与配置

#### 自动挂载

1. 修改`/etc/fstab`
    
2. 通过`udev`
3. 通过autofs实现
* 安装autofs
    `apt-get install autofs`
* autofs配置
    autofs的主要配置文件有两个，分别是/etc下的auto.master和auto.misc。其中，auto.master是起控制作用的，它定义了挂载点和automount动作的文件，例如`/misc /etc/auto.misc`就指定了auto.misc就是automount动作的文件，

#### windows 连接 samba
Windows 10用微软账户登录时，无法连接samba服务器，换本地用户登录就可以了。

“secpol.msc”打开管理工具，展开“本地策略”；
    然后，单击“安全选项”。 双击“网络安全：LAN Manager 身份验证级别”；
    最后，单击列表中：发送LM和NTLMv2，如果已协商，则使用NTLMv2协议。

### 其它应用
#### 摄像头
* vlc视频流输出
    
    raspivid -o - -t 0 -w 640 -h 360 -fps 25|cvlc -vvv stream:///dev/stdin --sout '#standard{access=http,mux=ts,dst=:8090}' :demux=h264 &> /dev/null 
    
* motion 做视频流服务器[](http://www.freebuf.com/news/special/61378.html)
* mjpg-stream 做视频流服务器[](http://blog.csdn.net/blueslime/article/details/12429411) 
    
### 备份

dosfstools：fat32分区格式化工具
dump：dump & restore 备份工具
parted & kpartx：虚拟磁盘工具

```bash
sudo apt-get install dosfstools dump parted kpartx
```

备份脚本

```bash
    #!/bin/sh
    sudo dd if=/dev/zero of=raspberrypi.img bs=1MB count=3000   # 新建备份镜像
    sudo parted raspberrypi.img --script -- mklabel msdos
    sudo parted raspberrypi.img --script -- mkpart primary fat32 8192s 122879s
    sudo parted raspberrypi.img --script -- mkpart primary ext4 122880s -1

    loopdevice=`sudo losetup -f --show raspberrypi.img`
    device=`sudo kpartx -va $loopdevice | sed -E 's/.*(loop[0-9])p.*/\1/g' | head -1`
    device="/dev/mapper/${device}"
    partBoot="${device}p1"
    partRoot="${device}p2"
    sudo mkfs.vfat $partBoot
    sudo mkfs.ext4 $partRoot
    sudo mount -t vfat $partBoot /media
    sudo cp -rfp /boot/* /media/
    sudo umount /media
    sudo mount -t ext4 $partRoot /media/
    cd /media
    sudo dump -0uaf - / | sudo restore -rf -
    cd
    sudo umount /media
    sudo kpartx -d $loopdevice
    sudo losetup -d $loopdevice
```




    

    



