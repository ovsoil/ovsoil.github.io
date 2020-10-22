---
layout: post
title: "Octopress个性化配置"
date: 2015-03-20 10:23
comments: true
categories: 
---

### zsh: no matches found: new_post[...]

原因是zsh解释[]字符的问题。可以使用转义符来解决这一问题，避免麻烦的话，在~/.zshrc中加入：

```bash
    alias rake="noglob rake"
```

### 中文title

为方便直接使用中文作为博客的标题，仿照new_post，建一个自己的任务post，包含两个参数，一个作为文件名，一个作为中文标题。
在Rakefile末尾增加如下代码：

```ruby
    desc "Begin a new post in #{source_dir}/#{posts_dir} with Alias"
    task :post, :title, :title_alias do |t, args|
      raise "### You haven't set anything up yet. First run `rake install` to set up an Octopress theme." unless File.directory?(source_dir)
      mkdir_p "#{source_dir}/#{posts_dir}"
      args.with_defaults(:title => 'new-post')
      title = args.title
      title_alias = args.title_alias
      filename = "#{source_dir}/#{posts_dir}/#{Time.now.strftime('%Y-%m-%d')}-#{title.to_url}.#{new_post_ext}"
      if File.exist?(filename)
        abort("rake aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
      end
      puts "Creating new post: #{filename}"
      open(filename, 'w') do |post|
        post.puts "---"
        post.puts "layout: post"
        post.puts "title: \"#{title_alias}\""
        post.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
        post.puts "comments: true"
        post.puts "categories: "
        post.puts "---"
      end
    end
```
使用：

```
    rake post["How to create octopress blog","如何建立Octopress博客"]
```

### 设置使用指定的编辑器自动打开新建的blog

每次用`rake　new_post`新建blog后都要手动打开编辑，果断google一下

在Rakefile中，找到## -- Misc Configs -- ##这段注释，然后在server_port下面加入editor = "open"
然后再找到new_post命令，在末尾加入如下代码：

```ruby
    if #{editor}
    system "#{editor} #{filename}"
    end
```

### 字体

Octopresss默认使用的是 google webfonts，遗憾的是在天朝不好用，而且它没有中文字体，所以你用粗体，没有效果。
所以，将source/_includes/custom/head.html中的两行代码注释掉，省去了加载字体，加快网页加载速度。

    <!--Fonts from Google"s Web font directory at http://google.com/webfonts -->
    <!-- <link href="http://fonts.googleapis.com/css?family=PT+Serif:regular,italic,bold,bolditalic" rel="stylesheet" type="text/css"> -->
    <!-- <link href="http://fonts.googleapis.com/css?family=PT+Sans:regular,italic,bold,bolditalic" rel="stylesheet" type="text/css"> -->

参考[最佳Web中文默认字体](http://lifesinger.wordpress.com/2011/04/06/best-web-default-fonts/)，在sass/custom/_fonts.scss 中添加如下三行代码：

    $heading-font-family: arial, sans-serif;
    $header-title-font-family: arial, sans-serif;
    $header-subtitle-font-family: arial, sans-serif;

刷新网页，可以看见中文的粗体变黑了。

### 语法高亮

#### pygnment

    ``` [language] [title] [url] [link text]
        code snippet
    ```
    [language] - Used by the syntax highlighter. Passing 'plain' disables highlighting. (Supported languages.)
    [title] - Add a figcaption to your code block.
    [url] - Download or reference link for your code.
    [Link text] - Text for the link, defaults to 'link'.

#### Gist代码内嵌

当使用这种方式的代码高亮时，仅仅需要的是gist的id，个人的理解gist是，gist对每段用户上传的代码段都会有一个对应的id，当用户给出对应的代码的id后，将会从gist上面下载对应的已经高亮的html文件，最终在用户的页面上显示出来。
语法

    { % gist gist_id [filename] %}

example

    { % gist 996818 %}
如果一个gist的id对应有多个文件，这时需要对想要高亮的文件添加文件名，具体语法如下所示：

    { % gist 1059334 svg_bullets.rb %}
    { % gist 1059334 usage.scss %}
总体来说，gist代码高亮是很简单的，只是需要将代码上传到gist，然后获取相应的id然后按照上面的语法进行设置即可。只是每次在写博客时，都需要对博客文章中的代码拷贝到网址上生成，在没有网时，代码高亮比较麻烦。

#### 使用Code Block的方式

目前自己的博客这种方式用的比较多，前面写的文章目前全部修改成为了这种方式，感觉这种方式和pygnment的方式差不多，之前全部采用的是pygnment的方式，利用正则表达式把所有文章的代码高亮全部改成了使用code block。它的具体语法如下所示：（与pygnment很相似，指定语言即可）

    { % codeblock [title] [lang:language] [url] [link text] %}
    code snippet
    { % endcodeblock %}
和之前描述的类似，中括号的内容是可选的。


### 只显示摘要

如果希望在首页每篇博文只显示一部分内容，例如摘要。可以在你的markdown文件中插入：`<!--more-->`，在这之前的作为摘要显示。
在_config.yml文件中修改`excerpt_link`的值`Read on`为以你想要的，比如`more`。

### 主题

### 导航栏

### 边栏

#### 分类
使用第三方插件 octopress-tagcloud 。
#### 友情链接
在 source\_includes\custom\asides 目录下添加一个blogroll.html文件，模仿about.html，添加一些友情链接，例如：

```html
    <section>
      <h1>友情链接</h1>
      <ul>
        <li>
          <a href="http://coolshell.cn/">酷壳CoolShell</a>
        </li>
        <li>
          <a href="http://mindhacks.cn/">刘未鹏MIND HACKS</a>
        </li>
        <li>
          <a href="http://blog.codingnow.com/">云风</a>
        </li>
        <li>
          <a href="http://www.cnblogs.com/Solstice/">陈硕</a>
        </li>
      </ul>
    </section>
```
然后在 _config.yml 文件中，在 default_asides 的数组中添加 custom/asides/blogroll.html

### 分享

使用[addthis.com](http://www.addthis.com)的分享按钮，在网站上获取代码，粘贴到 source/_includes/post/sharing.html 中，例如我的代码如下：

```html
    <div class="sharing">
      <!-- AddThis Button BEGIN -->
      <div class="addthis_toolbox addthis_default_style addthis_32x32_style">
        <a class="addthis_button_sinaweibo"></a>
        <a class="addthis_button_facebook"></a>
        <a class="addthis_button_twitter"></a>
        <a class="addthis_button_google_plusone_share"></a>
        <a class="addthis_button_delicious"></a>
        <a class="addthis_button_digg"></a>
        <a class="addthis_button_reddit"></a>
        <a class="addthis_button_compact"></a><a class="addthis_counter addthis_bubble_style"></a>
      </div>
      <script type="text/javascript" src="//s7.addthis.com/js/300/addthis_widget.js#pubid=undefined"></script>
      <!-- AddThis Button END -->
```
在_config.yml 中，将twitter, google+ 和facebook like的按钮设置为false，取消显示，因为 AddThis 已经集成了这三者。

### 评论

#### Disqus

octopress已为我们配置好了Disqus，我们只需要稍微填写以下信息即可。
1. 首先在Disqus 注册一个帐号，点击添加到我的网页，添加站点信息，比如我的ovsoil.github.io
2. 修改_config.yml文件，找到这一段：

        # Disqus Comments 
        disqus_short_name: 
        disqus_show_comment_count: false

添加你的disqus用户名，并把false修改成true即可。注意冒号后面有空格。

#### 多说
Disqus在国外流行，在国内的加载速度太慢，而且只有twitter, facebook, g+。其实这些都不是问题，问题是我这英语，还是不喝外国人交流了，所以替换成国内的[多说]() 。
参考[Octopress 添加多说评论系统]() 。
source/_includes/post/duoshuo_thread.html 的代码略有不同，添加了 data-title="我的Octopress配置" ，否则侧边栏的最近评论，标题为空白，代码如下：

```html
    <!-- Duoshuo Comment BEGIN -->
    <div class="ds-thread" data-title="我的Octopress配置"></div>
    <script type="text/javascript">
    var duoshuoQuery = {short_name:"yanjiuyanjiu"};
      (function() {
        var ds = document.createElement('script');
        ds.type = 'text/javascript';ds.async = true;
        ds.src = 'http://static.duoshuo.com/embed.js';
        ds.charset = 'UTF-8';
        (document.getElementsByTagName('head')[0]
        || document.getElementsByTagName('body')[0]).appendChild(ds);
      })();
    </script>
    <!-- Duoshuo Comment END -->
```

_config.yml 中的配置也略有不同：

    duoshuo_comments: true
    duoshuo_short_name: yanjiuyanjiu
    duoshuo_asides_num: 5      # 侧边栏评论显示条目数
    duoshuo_asides_avatars: 1   # 侧边栏评论是否显示头像
    duoshuo_asides_time: 1      # 侧边栏评论是否显示时间
    duoshuo_asides_title: 1     # 侧边栏评论是否显示标题
    duoshuo_asides_admin: 0     # 侧边栏评论是否显示作者评论
    duoshuo_asides_length: 32   # 侧边栏评论截取的长度

#### 添加评论
* 在 _config.yml 中添加

        # duoshuo comments
        duoshuo_comments: true
        duoshuo_short_name: yourname

* 在 `source/_layouts/post.html` 中的`disqus`代码下方添加 多说评论 模块

        {% if site.duoshuo_short_name and site.duoshuo_comments == true and page.comments == true %}
          <section>
            <h1>Comments</h1>
            <div id="comments" aria-live="polite">{% include post/duoshuo.html %}</div>
          </section>
        {% endif %}

如果你希望一些单独的页面下方也放置评论功能，譬如 rake new_page["xxx"] 产生的页面也能评论，那么请在 source/_layouts/page.html 中也做如上的修改。

* 然后就按路径创建一个 source/_includes/post/duoshuo.html

        <!-- Duoshuo Comment BEGIN -->
        <div class="ds-thread" data-title="{% if site.titlecase %}{{ page.title | titlecase }}{% else %}{{ page.title }}{% endif %}"></div>
        <script type="text/javascript">
          var duoshuoQuery = {short_name:"{{ site.duoshuo_short_name }}"};
          (function() {
            var ds = document.createElement('script');
            ds.type = 'text/javascript';ds.async = true;
            ds.src = 'http://static.duoshuo.com/embed.js';
            ds.charset = 'UTF-8';
            (document.getElementsByTagName('head')[0] 
            || document.getElementsByTagName('body')[0]).appendChild(ds);
          })();
        </script>
        <!-- Duoshuo Comment END -->

随后，再修改 _includes/article.html 文件，在`disqus`相关代码下方添加如下代码

         {% if site.duoshuo_short_name and page.comments != false and post.comments != false and site.duoshuo_comments == true %}
          | <a href="{% if index %}{{ root_url }}{{ post.url }}{% endif %}#comments">Comments</a>
         {% endif %}
当做这些步骤前，要先去多说网注册个帐号，添加站点，获取站点 short_name。

* 首页侧边栏插入最新评论
首先在 _config.yml 中再插入如下代码

        duoshuo_asides_num: 10      # 侧边栏评论显示条目数
        duoshuo_asides_avatars: 0   # 侧边栏评论是否显示头像
        duoshuo_asides_time: 0      # 侧边栏评论是否显示时间
        duoshuo_asides_title: 0     # 侧边栏评论是否显示标题
        duoshuo_asides_admin: 0     # 侧边栏评论是否显示作者评论
        duoshuo_asides_length: 18   # 侧边栏评论截取的长度

再创建 _includes/custom/asides/recent_comments.html

        <section>
        <h1>Recent Comments</h1>
        <ul class="ds-recent-comments" data-num-items="{{ site.duoshuo_asides_num }}" data-show-avatars="{{ site.duoshuo_asides_avatars }}" data-show-time="{{ site.duoshuo_asides_time }}" data-show-title="{{ site.duoshuo_asides_title }}" data-show-admin="{{ site.duoshuo_asides_admin }}" data-excerpt-length="{{ site.duoshuo_asides_length }}"></ul>
        {% if index %}
        <!--多说js加载开始，一个页面只需要加载一次 -->
        <script type="text/javascript">
          var duoshuoQuery = {short_name:"{{ site.duoshuo_short_name }}"};
          (function() {
            var ds = document.createElement('script');
            ds.type = 'text/javascript';ds.async = true;
            ds.src = 'http://static.duoshuo.com/embed.js';
            ds.charset = 'UTF-8';
            (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(ds);
          })();
        </script>
        <!--多说js加载结束，一个页面只需要加载一次 -->
        {% endif %}
        </section>

最后，`_config.yml` 中的`blog_index_asides`,`page_asides`,`post_asides` 添加`custom/asides/recent_comments.html`

### 插件

### 添加统计代码
在_config.yml填入 Google Analytics Tracking ID，例如 UA-7583537-4 。

### 在新电脑上恢复

参考 [Clone Your Octopress to Blog From Two Places](http://blog.zerosharp.com/clone-your-octopress-to-blog-from-two-places/) 。

```bash
    git clone -b source (url) octopress   #把source 克隆到本地octopress目录上
    cd octopress
    git clone (url) _deploy   #克隆master分支，它存放着博客内容。
    gem install bundler
    bundle install
    rake install
    rake setup_github_pages
```



### 参考
[Octopress主题改造](http://shanewfx.github.com/blog/2012/08/13/improve-blog-theme/)
