layout: post
title: Migrate From Octopress to Hexo
date: 2015-12-02 21:42:03
categories:
tags:
---




hexo出自台湾大学生tommy351之手，是一个基于Node.js的静态博客程序

**Hexo is Better than Octopress**：
* 速度快
* 简单

	   hexo n #写文章
	   hexo g #生成
	   hexo d #部署 # 可与hexo g合并为 hexo d -g

<!--more-->

## 安装

Node和Git都安装好后

	npm install -g hexo
	hexo init <folder> #也可以cd到目标目录，执行hexo init。
	hexo g
	hexo s
	
## 迁移
把Octopress `source/_posts` 文件夹内的所有文件转移到 Hexo 的 `source/_posts` 文件夹，并修改 `_config.yml` 中的 `new_post_name` 参数：

    new_post_name: :year-:month-:day-:title.md

其它类型blog迁移可以参考[Hexo中文Wiki](http://wiki.jikexueyuan.com/project/hexo-document/migration.html)

