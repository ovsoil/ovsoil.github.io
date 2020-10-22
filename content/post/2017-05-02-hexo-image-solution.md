---
layout: post
title: 不够优雅但很实用的Hexo博客图片方案
date: 2017-05-02 21:51:03
categories:
tags:
---


用hexo写博客很不错，但是图片引用一直是个问题，官方给的解决方案是用本地的[资源文件夹](https://hexo.io/zh-cn/docs/asset-folders.html)，但要完美工作还得放弃使用常规的markdown的语法来引用图片，转而使用一种特定的标签。这未免有点太不合理了。
```
{% asset_img example.jpg This is an example image %}
```
听说这个插件[hexo-asset-image](https://github.com/CodeFalling/hexo-asset-image)支持使用常规markdown语法，我没有试过。
另外，一般来说，我们部署hexo博客到github pages的同时，一般也会用git来管理我们的markdown源码。这就是说，我们就必须把本地的资源文件夹也一起用git管理，这不是一个好的选择，所以很多人选择了使用网络图床。但是图床又引入了一些新的问题，首先上传图片再拷贝url实在是太麻烦了，而且一些图床不支持https协议的话，还有可能被劫持，带来乱七八糟的广告。

所以，如果能够快速上传图片，同时自动插入对应的url，那在hexo中引用图片的体验就不错了

<!--more-->

### 注册图床

首先选一个图床，我用的七牛，不需要https的话，免费的已经够我用了。

具体的过程参考[Hexo文章图片存储选七牛](http://www.jianshu.com/p/ec2c8acf63cd)，或者官方文档[对象存储](https://developer.qiniu.com/kodo)

### 自动化脚本

我主要是用vim，所以这个方案也就只有vim才能用，而且写在vimrc里，很多东西都是hardcode的，所以一点都不优雅，但确实挺方便的。

使用方法就是:
1. 当需要引用图片时，在vim中输入该图片的相对路径，借助一些插件，在vim中输入文件目录也是可以补全的。可以参考我的[vimrc](https://github.com/ovsoil/vimrc)配置。
2. 然后vim切到可视模式，选中该路径，按快捷键`<space>ii`，该图片会自动上传到七牛图床，同时刚才选中的文本会被替换为图片对应的url。：）

vim 脚本如下，实现很简单，就是根据选中的图片路径，使用[qshell](https://developer.qiniu.com/kodo/tools/1302/qshell)上传图片到七牛存储，同时根据自己在七牛的域名得到url，并在vim中替换之前选中的文本。
所以，使用前，必须配置好qshell，然后把下面脚本中七牛分配的域名改成你自己的。

```vim
" Replace the selected text which is path of an image with URL in QiuNiu Cloudu
" Upload the image to QiuNiu Cloud
function! ReplaceWithQiuniuURL()
  " yank current visual selection to reg x
  normal gv"xy
  " get basename of the image
  let basename = fnamemodify(@x, ":t")
  " upload image to 'blog' bucket of qiniu cloud
  exe printf("!qshell fput blog %s %s", basename, @x)
  " put new string value in reg x
  let @x = printf("![Alt](http://cdn.ovsoil.cn/%s)", basename)
  " re-select area and delete
  normal gvd
  " paste new string value back in
  normal "xp
endfunction
vnoremap <leader>ii :call ReplaceWithQiuniuURL()<cr>
```

#### 其它改进

七牛还支持各种图片样式，通过在url后面加上样式名字就可以得到指定样式的图片。
这样获取固定尺寸图片，或者加水印图片就方便多了。
