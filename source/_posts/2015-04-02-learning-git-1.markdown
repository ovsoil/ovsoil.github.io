---
layout: post
title: "Git 学习之一"
date: 2015-04-02 16:56
comments: true
categories: 
---

## Git基本使用

Git是Linus用C实现的一个分布式版本控制工具，与Perforce、SVN和CVS这类集中式的版本控制工具不同。

* 每台机器都是一台服务器，无需依赖网络就可以帮自己的更新提交到本地服务器，支持离线工作。当有网络环境的时候，就可以把更新推送给其他服务器。
* 安全性高，每台机器都有代码以及版本信息的维护，所有即使某些机器挂掉了，代码依然是安全的。
* 在Git中，同步更新的方式有很多种，可以把自己的更新推送给别人；也可以生成一个diff的patch，通过邮件方式把这个patch发送给别人。

建议：虽然分布式版本控制没有服务端的概念，但一般在一个Git系统中，为了方便大家交换更新，会找一台机器作为中心服务器，这台机器的目地只是为了方便大家交换更新。即使这台中心服务器挂了，大家依然可以继续工作，只是相互之间交换更新比较麻烦。

<!--more-->

###安装与配置

    git config --global user.name “your user name”
    git config --global user.email “your email address”
    
    git config --global alias.st status #设置别名
###命令流


###本地初始化

    git init
    git add .
    git status
    git commit -m

###.gitignore

过滤语法

* 斜杠`/`开头表示目录
* 星号`*`通配多个字符
* 问号`?`通配单个字符
* 方括号`[]`包含单个字符的匹配列表
* 叹号`!`表示不忽略匹配到的文件或目录
下面举一些简单的例子：

`foo/*`：忽略目录 foo下的全部内容
`*.[oa]`：忽略所有.o和.a文件
`!calc.o`：不能忽略calc.o文件
exclude文件

在Git仓库中有一个`.git/info/exclude`文件，当我们指向对特定的仓库使用特定的过滤规则时，我们可以把过滤语句写在exclude文件中。
###版本回退

撤销WorkSpace中:`git checkout -- <file>…`。命令中的`--`很重要，没有`--`，就变成了“创建一个新分支”

撤销Stage中的更新:`git reset HEAD <file>…`

撤销repo中的更新：`git reset --hard commit_id`

穿梭前，用`git log`可以查看提交历史，以便确定要回退到哪个版本。要重返未来，用`git reflog`查看命令历史，以便确定要回到未来的哪个版本。

`HEAD`指向当前版本，所以也可以用下面的方式：

    git reset --hard HEAD^(HEAD^^, HEAD~~n)
    git reset --hard HEAD@{n}

`–hard`：撤销并删除相应的更新
`–soft`：撤销相应的更新，把这些更新的内容放的Stage中

###远程仓库

如果自己建立中心仓库，使用`git init –bare`。`–bare`表示创建的是一个裸仓库，之所以叫裸仓库是因为这个仓库只保存Git历史提交的版本信息，而不允许用户在上面进行各种git操作。

在github上新建中心仓库，根据wiki来就好。

添加远程仓库：`git remote add origin git@github.com:username/learngit.git`
查看远程仓库：`git remote`
更新至远程仓库：`git push -u origin master`

由于远程库是空的，我们第一次推送master分支时，加上了-u参数，Git不但会把本地的master分支内容推送的远程新的master分支，还会把本地的master分支和远程的master分支关联起来，在以后的推送或者拉取时就可以简化命令。

从远程仓库克隆时，实际上Git自动把本地的master分支和远程的master分支对应起来了，并且，远程仓库的默认名称是origin。
    
    git clone ...

利用`--set-upstream-to`建立本地分支与上游分支的关联：`git branch --set-upstream-to=origin/remoteBranch localBranch`
当然，在Git中我们可以直接通过`git checkout -b localBranchName origin/remoteBranchName`来创建关联分支。建议一般把”localBranchName”名称跟”remoteBranchName”名称设置成一样。


我们独立开发时，经常在github网站上新建一个仓库，在这里写上Readme.md, license和.gitignore，再把本地代码合并上去，但由于本地和远程都有工作树，push会被rejected。必须先把远程仓库合并到本地，然后再push：

    git pull https://github.com/username/repository master
    git push -u origin master

###分支

查看分支：`git branch`   
创建分支：`git branch <name>`  
切换分支：`git checkout <name>`  
创建+切换分支：`git checkout -b <name>`  
合并某分支到当前分支：`git merge <name>`  
删除分支：`git branch -d <name>`  
强行删除：`git branch -D <name>`
查看分支的合并情况：`git log --graph --pretty=oneline --abbrev-commit`

合并分支时，加上--no-ff参数就可以用普通模式合并，合并后的历史有分支，能看出来曾经做过合并，而fast forward合并就看不出来曾经做过合并。

在实际开发中，我们应该按照几个基本原则进行分支管理：

首先，master分支应该是非常稳定的，也就是仅用来发布新版本，平时不能在上面干活；

那在哪干活呢？干活都在dev分支上，也就是说，dev分支是不稳定的，到某个时候，比如1.0版本发布时，再把dev分支合并到master上，在master分支发布1.0版本；

你和你的小伙伴们每个人都在dev分支上干活，每个人都有自己的分支，时不时地往dev分支上合并就可以了。

###stash

    git stash
    git stash list
    git stash apply
    git stash drop
    git stash pop
###工作流
* bug分支
* feature分支

多人协作的工作模式通常是这样：

首先，可以试图用git push origin branch-name推送自己的修改；

如果推送失败，则因为远程分支比你的本地更新，需要先用git pull试图合并；

如果合并有冲突，则解决冲突，并在本地提交；

没有冲突或者解决掉冲突后，再用git push origin branch-name推送就能成功！

如果git pull提示“no tracking information”，则说明本地分支和远程分支的链接关系没有创建，用命令git branch --set-upstream branch-name origin/branch-name。

###标签

* 命令`git tag <name>`用于新建一个标签，默认为`HEAD`，也可以指定一个`commit id`；
* `git tag -a <tagname> -m "blablabla..."`可以指定标签信息；
* `git tag -s <tagname> -m "blablabla..."`可以用PGP签名标签；
* `git tag`可以查看所有标签。
* 
* `git push origin <tagname>`可以推送一个本地标签；
* `git push origin --tags`可以推送全部未推送过的本地标签；
* `git tag -d <tagname>`可以删除一个本地标签；
* `git push origin :refs/tags/<tagname>`可以删除一个远程标签。

