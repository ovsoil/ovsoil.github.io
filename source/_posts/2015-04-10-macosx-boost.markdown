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



vim中连续jkhl

defaults write -g ApplePressAndHoldEnabled -bool false


### 日常应用篇

### 开发环境篇

####  Basic
搭建开发环境首先要安装的就是Xcode的Command Line Tools:`xcode-select --install`。安装之后就可以使用Mac下的c语言编译器clang、C++编译器clang++，调试器lldb了。

接下来安装和配置一些常用工具，包括包管理工具, zsh, Vim, git的安装配置。

1. brew

包管理工具已经成为现在操作系统中不可缺少的一个重要工具了，它能大大减轻软件安装的负担，节约我们的时间。Linux中常用的有yum和apt-get工具，甚至Windows平台也 有Chocolatey这样优秀的工具，在OSX中，有两款大家常用的管理工具：Homebrew或者MacPorts。Homebrew被越多人推荐， 因为Homebrew不会破坏OSX 原生的环境，她安装的所有文件都是在用户独立空间内 的，这让你安装的所有软件对于该用户来说都是可以访问的，不需要使用sudo。

- Home Brew：Mac下最好用的包管理工具
- brew-cask：用来装GUI程序的包管理工具
    ```bash
    brew tap caskroom/cask  # 添加 Github 上的 caskroom/cask 库
    brew install brew-cask  # 安装 brew-cask
    brew cask install google-chrome # 安装 Google 浏览器
    brew update && brew upgrade brew-cask && brew cleanup # 更新
    # add this in .bashrc&.zshrc to change the repo
    export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles
    ```
- LaunchRocket： 图形化的Service管理工具，可以直接用brew-cask命令安装
    ```bash
    brew tap jimbojsb/launchrocket
    brew cask install launchrocket
    ```

2. iTerm2
    ```bash

    ```

3. Oh-My-Zsh

    ```bash
    # install
    wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
    # add plugin(zsh-nvm for example)
    git clone https://github.com/lukechilds/zsh-nvm ~/.oh-my-zsh/custom/plugins/zsh-nvm
    # load in your .zshrc
    plugins+=(zsh-nvm)
    ```

4. tmux

* install

- 推荐这个配置[gpakosz/.tmux](https://github.com/gpakosz/.tmux.git)
    ```bash
    # install
    cd
    rm -rf .tmux
    git clone https://github.com/gpakosz/.tmux.git
    ln -s .tmux/.tmux.conf
    cp .tmux/.tmux.conf.local .
    ```

- Install Tmux Plugin Manageer
    ```bash
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    ```
    Put this at the bottom of .tmux.conf:
    ```bash
    # List of plugins
    set -g @plugin 'tmux-plugins/tpm'
    set -g @plugin 'tmux-plugins/tmux-sensible'

    # Other examples:
    # set -g @plugin 'github_username/plugin_name'
    # set -g @plugin 'git@github.com/user/plugin'
    # set -g @plugin 'git@bitbucket.com/user/plugin'

    # Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
    run '~/.tmux/plugins/tpm/tpm'
    ```
    Reload TMUX environment so TPM
    ```bash
    tmux source ~/.tmux.conf
    ```
    Use
    `prefix + I`: Installs new plugins from GitHub or any other git repository Refreshes TMUX environment
    `prefix + U`: updates plugin(s)

5. vim

6. emacs(spacemacs)

7. tools
    ```bash
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
    ```

#### language

1. C/C++

2. java

3. python

```bash
export WORKON_HOME=~/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh
# alias ipython to ipy
alias ipy="python -c 'import IPython; IPython.terminal.ipapp.launch_new_instance()'"
```
4. javascript

5. nodejs

- [nvm](https://github.com/creationix/nvm)
    ```bash
    # install nvm
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash
    # If you're using zsh you can easily install nvm as a zsh plugin. Install zsh-nvm and run nvm upgrade to upgrade
    git clone https://github.com/lukechilds/zsh-nvm ~/.oh-my-zsh/custom/plugins/zsh-nvm
    # load in your .zshrc and restart zsh
    plugins+=(zsh-nvm)
    # upgrade nvm
    nvm upgrade
    # nvm use node
    npm install -g cnpm --registry=https://registry.npm.taobao.org
    ```

- hexo
    ```bash
    cnpm install hexo-cli -g
    hexo init blog
    cd blog
    cnpm install
    hexo server
    ```

### 软件清单

最后列一下其它一些有用的软件

* 终端
- TotalTerminal

* 编辑器
- sublime_text_2
- atom

* 开发
- Valgrind 动态分析工具
- guard-livereload 本地网页自动重载
- IntelliJ IDEA Guide
- jekyll
- hexo
