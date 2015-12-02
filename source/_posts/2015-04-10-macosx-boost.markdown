---
layout: post
title: "MacOSX使用与开发环境搭建"
date: 2015-04-10 13:17
comments: true
categories: 
---

每次更换系统或者更换电脑的时候，都免不了花时间去折腾开发环境的问题。我深知这个过程的繁琐和浪费时间，但有时候仍然乐此不疲，或许是强迫症作祟。所以真的有必要在这里整理一下。欢迎补充修正。

<!--more-->

### Terminal篇

包括包管理工具, zsh, Vim, git的安装配置。

Homebrew, 你不能错过的包管理工具

包管理工具已经成为现在操作系统中不可缺少的一个重要工具了，它能大大减轻软件安装的 负担，节约我们的时间。Linux中常用的有yum和apt-get工具，甚至Windows平台也 有Chocolatey这样优秀的工具，OSX平台自然有它独有的工具。

在OSX中，有两款大家常用的管理工具：Homebrew或者MacPorts。这两款工具都是为了解决同 样的问题——为OSX安装常用库和工具。Homebrew与MacPorts的主要区别是Homebrew不会破坏OSX 原生的环境，这也是我推荐Homebrew的主要原因。同时它安装的所有文件都是在用户独立空间内 的，这让你安装的所有软件对于该用户来说都是可以访问的，不需要使用sudo命令。


vim中连续jkhl

    defaults write -g ApplePressAndHoldEnabled -bool false


### 日常应用篇

### 开发环境篇



### 软件清单

最后列一下我的MacOSX软件清单

* 终端
oh-my-sh
TotalTerminal

* 编辑器
sublime_text_2
vim 模式
    "ignored_packages": []

* 开发
- Valgrind 动态分析工具
- guard-livereload 本地网页自动重载
- jekyll
- hexo
- nvm
- IntelliJ IDEA Guide
