---
layout: post
title: "MacOSX 使用小贴士"
date: 2015-07-10 14:01
comments: true
categories: MacOS 
---

使用MacBookPro有一段时间了，有一些有用的使用技巧能够极大的提高了工作学习效率，一直很想记录并分享出来。当然里面有一些习惯带我个人的习惯，不认同的忽略就好。

<!--more-->

## 基本的使用习惯
1. 默认情况下左键点击操作需要按下触摸板，我相信对于大多数人来说，轻触即为点击更为友好：
选择`System Preferences` > `Trackpad`，在`Point & Click`标签页中选中`Tap to click`。

2. 默认情况下，`F1`~`F12`是特殊功能键，而当需要键入`F1`~`F12`时，需要按住`Fn`，这并不符合我的习惯。
把 `F1`~`F12` 改成标准功能键：选择`System Preferences` > `Keyboard`，选中`Use all F1, F2, etc. keys as standard function keys`。

3. 更改`Caps Lock`键为`Control`键
很多程序员都喜欢这样的改动，确实`Caps Lock`键也真的很少用而Contrl键很常用，这样改敲起来会更顺手一点，也为以后换HHKB键盘做个准备。
设置方法：选择`System Preferences` > `Keyboard`，在`Keyboard`标签页中点击`Modifier Keys...`按钮，在弹出的窗口中，把`Caps Lock (⇪) Key`:对应的选项改成`⌃ Control`。



## 快捷键
一般来说，尽量使用键盘，手基本不离开键盘，少使用鼠标和触摸板，可以大大提高效率。

MacBook的快捷键有详细的官方文档：
[Mac keyboard shortcts](https://support.apple.com/kb/HT201236)
[Mac keyboard shortcuts for accessibility features](https://support.apple.com/kb/HT204434)

下面记几个有用的：

1. `cmd+shift+3` 为全屏截图。`cmd+shift+4` 为区域截图，而且此时单击空格键会截取当前窗口。



## 常用软件

解压缩：the Unarchiver（App Store直接安装）
视频播放器：MPlayer X, VLC, mpv
MarkDown编辑器：Mou
终端：iTerm2
Android手机数据传输：Android File Transfer

## 基本开发环境

1. 首先是Xcode的Command Line Tools，安装：`xcode-select --install`。安装之后就可以使用Mac下的c语言编译器clang、C++编译器clang++，调试器lldb了。

2. Oh-My-Zsh
    `wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh`

3. brew

- Home Brew：Mac下最好用的包管理工具
- brew-cask：用来装GUI程序的包管理工具
```bash
$ brew tap caskroom/cask  // 添加 Github 上的 caskroom/cask 库
$ brew install brew-cask  // 安装 brew-cask
$ brew cask install google-chrome // 安装 Google 浏览器
$ brew update && brew upgrade brew-cask && brew cleanup // 更新
```
- LaunchRocket： 图形化的Service管理工具，可以直接用brew-cask命令安装

        brew tap jimbojsb/launchrocket
        brew cask install launchrocket


## 精简磁盘空间

使用`sudo du -h -d1 /`查看根目录使用情况，发现有一个`.MobileBackups`占用了20G，上网一查这个目录是TimeMachine的本地快照。

官网说明：OS X Lion 及更高版本中的Time Machine 包含一项称为“本地快照”的功能。当您的备份驱动器不可用时，此功能可保留您在内置磁盘上创建、修改或删除的文件的副本。
仅当启动磁盘上有大量可用磁盘空间时，Time Machine 才用于存储本地快照。这意味着您可以根据需要继续使用可用磁盘空间。
如果磁盘空间不足，则 Time Machine 会停止创建新快照。系统可能会删除部分或全部快照，以便为要使用的应用软件腾出空间。如果再次获得充足的磁盘空间，Time Machine 会继续创建本地快照。这意味着如果未启用 Time Machine，磁盘的可用空间大小与实际大小相同。Time Machine 使用以下规则来确定是停止创建快照还是删除现有快照。

* 当您的启动磁盘可用空间不到总可用空间的 20% 时，Time Machine 会从最早的快照开始删除快照。随后它会根据需要删除较新的快照，从而保留最新的快照，直到删除最后一个。如果稍后可用驱动器空间再次达到 20% 以上，则 Time Machine 会停止删除快照。
* 如果您的启动磁盘可用空间不到总可用空间的 10% 或小于 5 GB，则优先在 Mac 上删除快照。当可用空间为总可用空间的 10%–20% 时，删除快照这项任务仍然具有普通优先级。
* 如果 Time Machine 无法释放足够的空间来达到 10% 或 5 GB 的阈值，则 Time Machine 会删除所有快照（仅保留最新的快照），并停止创建新快照。当可用空间超过此阈值时，系统会创建新快照并删除之前的快照。

从 Apple 菜单中选择“关于本机”,“储存空间”标签以查看可用和已用磁盘空间,本地快照占用的空间标记为“备份”。

删除方法
```bash
    sudo tmutil disablelocal    #关闭自动备份
    rm -rf .MobileBackups
    sudo tmutil enablelocal     #开启自动备份
```

## Tips

1. 重置 Launchpad 上图标位置
`defaults write com.apple.dock ResetLaunchPad -bool true; killall Dock`

2. 在Finder中经常会想要获取当前目录的路径，或者在终端中进入当前目录，下面几种方法可能有用。

- `cmd+option+p`可以在窗口下方显示路径栏；
- `defaults write com.apple.finder _FXShowPosixPathInTitle -bool YES`可以使Finder的标题显示完整路径；
- 另外在最新的OSX EI Capitan(10.11)中，`cmd+option+c` 会复制当前文件夹路径。

## 参考文章

[强迫症的Mac设置指南](https://github.com/macdao/ocds-guide-to-setting-up-mac?hmsr=toutiao.io&utm_medium=toutiao.io&utm_source=toutiao.io)
[程序员如何优雅的使用Mac](http://www.zhihu.com/question/20873070)
[高效Macbook开发之道(工具篇)](http://wuchong.me/blog/2015/11/21/macbook-productive-tools/?hmsr=toutiao.io&utm_medium=toutiao.io&utm_source=toutiao.io)

