---
layout: post
title: "octopress 博客搭建"
date: 2015-03-17 09:39:33
comments: true
categories:
---

## 介绍

### Jekyll
Jekyll一个简单的博客形态的静态站点生产机器。Jekyll 有一套模板目录，可以将 Markdown文件（或者Textile）转换为静态网页，并生成一个完整的可发布的静态网站。
### Octopress
[Octopress](http://octopress.org)是基于 Jekyll 的博客框架。他们的关系就像 jQuery 与 js 的关系一样。它为我们提供了现成的美观的主题模板，并且配置简单，使用方便，大大降低了我们建站的门槛。
### Ruby
Ruby是一种编程语言，Octopress是用Ruby实现的。
### Github
GitHub 是全球最热的开源社区，提供代码托管服务，以及我们搭建博客所需要的Pages服务。

<!--more-->

## 工具
### rbenv
### Bundle介绍：
Rails 3中引入Bundle来管理项目中所有gem依赖，该命令只能在一个含有Gemfile的目录下执行。
所有Ruby项目的信赖包都在Gemfile中进行配置，不再像以往那样，通过require来查找。Rails 3中如果require某个gem包，必须通过修改Gemfile文件来管理。
Gemfile.lock则用来记录本机目前所有依赖的Ruby Gems及其版本。所以强烈建议将该文件放入版本控制器，从而保证大家基于同一环境下工作。
Bundle命令详解：

    # 显示所有的依赖包
    $ bundle show

    # 显示指定gem包的安装位置
    $ bundle show [gemname]

    # 检查系统中缺少那些项目以来的gem包
    $ bundle check

    # 安装项目依赖的所有gem包, 并尝试更新系统中已存在的gem包
    $ bundle install

    # 安装指定的gem包
    $ bundle install [gemname]

    # 更新系统中存在的项目依赖包，并同时更新项目Gemfile.lock文件
    $ bundle update

    # 更新系统中指定的gem包信息，并同时更新项目Gemfile.lock中指定的包信息
    $ bundle update [gemname]

<!--more-->

## 搭建
### Octopress

先卸载MacPorts

    sudo prot -f uninstall installed
    sudo rm -fr \
安装brew

    curl -L http://github.com/mxcl/homebrew/tarball/master | tar xz –strip 1 -C /usr/local

    git clone git://github.com/imathis/octopress.git octopress
    cd octopress
    gem install bundler
    rbenv rehash
    bundle install
    rake install


配置Octopress

编辑 config.yml文件的url,title,subtitle,author。

最好把里面的twitter相关的信息全部删掉，否则由于GFW的原因，将会造成页面load很慢。同理，修改定制文件/source/_includes/custom/head.html 把google的自定义字体去掉。

安装支持新浪微博和Dribbble的Octopress的Greyshade主题

我现在用的就是greyshade主题 http://www.sgxiang.com

 cd octopress

 git clone git@github.com:allenhsu/greyshade.git .themes/greyshade

 echo "\$greyshade: color;" >> sass/custom/_colors.scss //替换 color 为自定义的链接高亮颜色

 rake "install[greyshade]"
在_config.yml中加入

weibo_user: xsxiang # 微博数字 ID 或域名 ID
dribbble_user: 
weibo_share: true # 是否开启微博分享按钮
关于greyshade主题的头像问题，有两种途径可以设置头像

在_config.yml文件中设置一个email，然后到gravatar网站上添加该email并上传一张头像
将需要使用的图片放到/source/images下。然后把/source/_includes/header.html文件中的img替换成 《img alt=“Profile Picture” src=“/images/tx.png” style=“width:160px;”》
配置Disqus插件

Disqus是octopress内置的comments功能，编辑config.yml文件可以打开该功能，找到以下内容修改

    #Disqus comments
    disqus_short_name: 
    disqus_show_comment_count: false
填入注册disqus账号的名称，并将false修改为true。【disqus要和自己的username.github.com关联上】

### 博客部署

1. 官方推荐了3种部署方式：

* github，部署允许自定义域名，免费，好处是多人开发更方面，坏处是文件随时可以被任何人拉下来。

* heroku，部署允许自定义域名，免费，并且是私有的。

* rsync，建议用来部署有自己服务器的个人博客。


2. 配置github相关

在本机创建ssh

cd ~/.ssh
ssh-keygen -t rsa -C 你注册github时的email
弹出Enter file in which to save the key (/Users/twer/.ssh/id_rsa):直接按空格

弹出Enter passphrase (empty for no passphrase):输入你github账号的密码。Enter same passphrase again:再次输入你的密码。

打开~/.ssh下的id_rsa.pub文件复制里面的全部内容。
登陆github，选择Account Settings-->SSH Public Keys 添加ssh，把剪切板的内容复制到key输入框内直接保存。

测试shh:

ssh git@github.com
输出

PTY allocation request failed on channel 0
Hi username! You've successfully authenticated, but GitHub does not provide shell access.
Connection to github.com closed.
代表成功

建立一个仓库

登陆github创建一个仓库 ，仓库名称为username.github.com比如我的是sgxiang.github.com

3. 部署博客到github

利用octopress的一个配置rake任务来自动配置上面创建的仓库：可以让我们方便的部署GitHub page。在终端输入如下命令：

    rake setup_github_pages
弹出之后输入博客仓库地址：

    git@github.com:your_username/your_username.github.com.git
通过以下命令部署博客

    rake generate
    rake deploy

博客的source需要单独提交，执行如下命令就可以将source提交到仓库的source分支下

    git add .
    git commit -m 'Initial source commit'
    git push origin source
本地预览，输入rake preview之后在浏览器输入http://localhost:4000/来访问

4. 写博客

新建博客

    rake new_post["myTitle"]
文章生成在目录下的source/_posts目录下。文章完成后就更新到github上:

    rake generate
    git add .
    git commit -am "Some comment here." 
    git push origin source
    rake deploy


5. 自定义

[主题](https://github.com/imathis/octopress/wiki/3rd-Party-Octopress-Themes)

安装

	cd yourOctopress
	git submodule add GIT_URL .themes/THEME_NAME
    git submodule update --init
	rake install['THEME_NAME'] #for zsh, use: rake install\['THEME_NAME'\] 
	rake generate
更新

    cd yourOctopress
    git submodule update
    rake generate

6. Tips:

* 图片
    如果要在文章中上传图片，直接 copy 到 /source/images 目录下即可。在文章中可以直接引用。也可以选一些大的图床站点，例如 flickr 之类的放在那边。

* 域名
如果你象我一样有自己的域名，可以将域名指向这个博客，具体步骤是：

在域名管理中，建立一个 CNAME 指向，将你的域名指向 yourname.github.io
建一个名为 CNAME 的文件在 source 目录下，然后将自己的域名输入进去。
将内容 push 到 github 后，第一次生效大概等 1 小时，之后你就可以用自己的域名访问了。

* 原理
Octopress 其实为你建立了 2 个分支，一个是 master 分支，用于存放生成的最终网页。另一个是 source 分支，用于存放最初的原始 markdown 文件。
平时写作和提交都在 source 分支下，当需要发布时，rake deploy 命令会将内容生成到 public 这个目录，然后将这个目录的内容当作 master 分支的内容同步到 github 上面。

