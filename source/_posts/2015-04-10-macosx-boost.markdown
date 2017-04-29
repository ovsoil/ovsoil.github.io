---
layout: post
title: "MacOSX使用与开发环境搭建"
date: 2015-04-10 13:17
comments: true
categories: 
---

每次更换系统或者更换电脑的时候，都免不了花时间去折腾开发环境的问题。我深知这个过程的繁琐和浪费时间，但有时候仍然乐此不疲，或许是强迫症作祟。所以真的有必要在这里整理一下。欢迎补充修正。

<!--more-->

### 日常应用篇

### 开发环境篇

* screen: 特别是 ssh 到登录远程时用以管理会话
* curl: 网络请求, 相关的还有 traceroute, dig 等
* find: 文件查找
* grep/zgrep/zcat: 查看日志的时候用
* awk: 这个本身就很强大了, 具体编程语法不用太掌握但可以了解一些基本的用法, 比如之前用到过给一个log文件, 能够取里面的参数拼接update 的sql(文件里有相应 update 的值和 where 条件值)
* sed: 文本替换, 还有 tr, 注意 sed 的语法 Mac 和 一般 Linux 还有些不一样( 比如原文替换的时候 mac 里需要用参数 -i ""), 比如之前迁移 wordpress 到 jekyll 上的时候需要将一些链接整体替换成新的路径.
* cut: 按列取数据, awk 也可以
* sort: 这个就不多说了
* uniq: 一般和 sort 一块用, 只能去重相邻的行
* diff: 比较文件, 类似的还有 comm (输出3列, 分别是: 只在文件1, 只在文件2 和两个文件都在的行)
* paste: 两个文件按列拼接
* od: 以16/8/2进制查看文件
* wc: 统计文件字节数/字数/行数
* openssl sha1/aes-256-ecb/des/base64 等等: 比如当前我们开发用的 MVC 框架play framework用来加密 session 的算法, 可以方便算出 encoded 的 sessionid 进行 debug.
* md5/base64: 常见的 md5, base64 编码
* sips: scriptable image processing system 比如批量处理图片大小, 压缩等等


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

*  ag

* fzf
    ```bash
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
    ```
    *use*
    ctrl+t
    **<tab>
    processid: kill -9 <tab>

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
