---
layout: post
title: "Git 学习之二"
date: 2015-04-03 09:15
comments: true
categories: 
---

## Git 进阶

前面记录了Git的一些基本使用，这里补充深入一些的东西。

<!--more-->


### 细看远程仓库命令

* 查看有用的信息:

        git branch
        git remote

* push命令用来将本地分支的更新推送的远程仓库

通过”git push”更新、创建远程分支


通过”git push”删除远程分支


省略分支信息的”git push origin”
通过这种方式push的时候，报出了一个警告，提示”push.default”没有设置。

在Git中push有两种设置：

simple方式：只是推送当前分支的更新到对应的远程分支；在Git 2.0以后就默认使用这种方式
matching方式：会推送所有有对应的远程分支的本地分支

根据Git的提示，我们可以通过”git config –global push.default”来设置push方式。

* pull命令的作用是取回远程某个分支的更新，然后合并到指定的本地分支

取回origin主机release-1.0分支的更新，与本地的release-1.0分支合并:`git pull origin release-1.0:release1.0`

一般来说，pull命令都是在关联的本地分支和远程分支之间进行；当然，你可以使用不关联的本地分支和远程分支进行pull操作，但是不建议这么做。

如果真的需要别的远程分支上的更新，建议使用”cherry-pick”把这个更新拿到关联的远程分支上，然后在关联分支上进行pull操作。

省略本地分支名：git pull origin release-1.0
表示取回origin/next远程分支的更新，然后合并到当前分支

如果当前分支存在上游（关联）分支，可以直接使用git pull origin
表示本地的当前分支自动与关联的origin主机分支进行合并

“git pull”操作实际上等价于，先执行”git fetch”获得远程更新，然后”git merge”与本地分支进行合并。

当然，pull命令也支持使用rebase模式进行合并：

git pull --rebase <远程主机名> <远程分支名>:<本地分支名>
在这种情况下，”git pull”就等价于”git fetch”加上”git rebase”。

建议使用”git fetch”加上”git rebase”的方式来取代”git pull”获取远程更新，具体原因后面再介绍。

git fetch

fetch命令比较简单，作用就是将远程的更新取回到本地。

git fetch origin
该命令表示将远程origin主机的所有分支上的更新取回本地

git fetch origin master
该命令只取回远程origin主机上master分支上的更新

### merge和rebase

merge会有三种情况：

* 当目标分支是当前分支的祖先commit节点，也就是说当前分支已经是最新的了，merge命令没有任何效果。
* 当前分支是目标分支的祖先commit节点时，会发生Fast-forward的merge
* merge命令中加上”–no-ff”进行合并操作

cherry-pick

在实际应用中，我们可能会经常碰到这种情况，在分支A上提交了一个更新，但是后来发现我们同样需要在分支B上应用这个更新。
”git reflog”找到A上那个更新的SHA1哈希值，然后切换到B分支上使用”git cherry-pick”。当我们手动合并过冲突，然后继续执行”cherry-pick”时候，Git会给出友好的交互界面，如果我们不需要更新这个提交的message

rebase和merge的差别主要是：

rebase更清晰，因为commit历史是线性的，但commit不一定按日期先后排，而是当前分支的commit总在后面（参考rebase原理）
merge之后commit历史变得比较复杂，并且一定程度上反映了各个分支的信息，而且 commit按日期排序的。



###搭建git服务器

在远程仓库一节中，我们讲了远程仓库实际上和本地仓库没啥不同，纯粹为了7x24小时开机并交换大家的修改。

GitHub就是一个免费托管开源代码的远程仓库。但是对于某些视源代码如生命的商业公司来说，既不想公开源代码，又舍不得给GitHub交保护费，那就只能自己搭建一台Git服务器作为私有仓库使用。

搭建Git服务器需要准备一台运行Linux的机器，强烈推荐用Ubuntu或Debian，这样，通过几条简单的apt命令就可以完成安装。

假设你已经有sudo权限的用户账号，下面，正式开始安装。

第一步，安装git：

$ sudo apt-get install git
第二步，创建一个git用户，用来运行git服务：

$ sudo adduser git
第三步，创建证书登录：

收集所有需要登录的用户的公钥，就是他们自己的id_rsa.pub文件，把所有公钥导入到/home/git/.ssh/authorized_keys文件里，一行一个。

第四步，初始化Git仓库：

先选定一个目录作为Git仓库，假定是/srv/sample.git，在/srv目录下输入命令：

$ sudo git init --bare sample.git
Git就会创建一个裸仓库，裸仓库没有工作区，因为服务器上的Git仓库纯粹是为了共享，所以不让用户直接登录到服务器上去改工作区，并且服务器上的Git仓库通常都以.git结尾。然后，把owner改为git：

$ sudo chown -R git:git sample.git
第五步，禁用shell登录：

出于安全考虑，第二步创建的git用户不允许登录shell，这可以通过编辑/etc/passwd文件完成。找到类似下面的一行：

git:x:1001:1001:,,,:/home/git:/bin/bash
改为：

git:x:1001:1001:,,,:/home/git:/usr/bin/git-shell
这样，git用户可以正常通过ssh使用git，但无法登录shell，因为我们为git用户指定的git-shell每次一登录就自动退出。

第六步，克隆远程仓库：

现在，可以通过git clone命令克隆远程仓库了，在各自的电脑上运行：

$ git clone git@server:/srv/sample.git
Cloning into 'sample'...
warning: You appear to have cloned an empty repository.
剩下的推送就简单了。

管理公钥
如果团队很小，把每个人的公钥收集起来放到服务器的/home/git/.ssh/authorized_keys文件里就是可行的。如果团队有几百号人，就没法这么玩了，这时，可以用Gitosis来管理公钥。

这里我们不介绍怎么玩Gitosis了，几百号人的团队基本都在500强了，相信找个高水平的Linux管理员问题不大。

管理权限
有很多不但视源代码如生命，而且视员工为窃贼的公司，会在版本控制系统里设置一套完善的权限控制，每个人是否有读写权限会精确到每个分支甚至每个目录下。因为Git是为Linux源代码托管而开发的，所以Git也继承了开源社区的精神，不支持权限控制。不过，因为Git支持钩子（hook），所以，可以在服务器端编写一系列脚本来控制提交等操作，达到权限控制的目的。Gitolite就是这个工具。



