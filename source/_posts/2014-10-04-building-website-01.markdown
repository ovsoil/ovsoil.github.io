---
layout: post
title: "建站之一"
date: 2014-10-04 13:00
comments: true
categories: 
---

##基础


<!--more-->

###A(Address)记录

是用来指定主机名（或域名）对应的IP地址记录。用户可以将该域名下的网站服务器指向到自己的web server上。同时也可以设置您域名的二级域名。

###CNAME

也被称为规范名字。这种记录允许您将多个名字映射到同一台计算机。 通常用于同时提供WWW和MAIL服务的计算机。例如，有一一个A记录为host.mydomain.com。 它同时提供WWW和MAIL服务，为了便于用户访问服务。可以为该计算机设置两个别名（CNAME）：WWW和MAIL。 这两个别名的全称就是www.mydomain.com和mail.mydomain.com，将他们都指向host.mydomain.com：

    A
    host.mydomain.com -> IPAddress
    CNAME
    www.mydomain.com -> host.mydomain.com
    mail.mydomain.com -> host.mydomain.com

同样的方法可以用于当您拥有多个域名需要指向同一服务器IP，此时您就可以将一个域名做A记录指向服务器IP然后将其他的域名做别名到之前做A记录的域名上，那么当您的服务器IP地址变更时您就可以不必麻烦的一个一个域名更改指向了 只需要更改做A记录的那个域名其他做别名的那些域名的指向也将自动更改到新的IP地址上了。CNAME还广泛用于需要CDN加速的场景下，因为这个时候，域名到IP地址的映射是事先不知道的，需要根据访问者的地理位置来确定镜像服务器的IP地址。
###TTL

TTL值全称是“生存时间（Time To Live)”，简单的说它表示DNS记录在DNS服务器上缓存时间。要理解TTL值，请先看下面的一个例子：

假设，有这样一个域名myhost.cnMonkey.com（其实，这就是一条DNS记录，通常表示在abc.com域中有一台名为myhost的主机）对应IP地 址为1.1.1.1，它的TTL为10分钟。这个域名或称这条记录存储在一台名为dns.cnMonkey.com的DNS服务器上。 现在有一个用户键入一下地址（又称URL）：http://myhost.cnMonkey.com 这时会发生什么呢？ 该 访问者指定的DNS服务器（或是他的ISP,互联网服务商, 动态分配给他的)8.8.8.8就会试图为他解释myhost.cnMonkey.com，当然8.8.8.8这台DNS服务器由于没有包含 myhost.cnMonkey.com这条信息，因此无法立即解析，但是通过全球DNS的递归查询后，最终定位到dns.cnMonkey.com这台DNS服务器， dns.cnMonkey.com这台DNS服务器将myhost.cnMonkey.com对应的IP地址1.1.1.1告诉8.8.8.8这台DNS服务器，然有再由 8.8.8.8告诉用户结果。8.8.8.8为了以后加快对myhost.cnMonkey.com这条记录的解析，就将刚才的1.1.1.1结果保留一段时间，这 就是TTL时间，在这段时间内如果用户又有对myhost.cnMonkey.com这条记录的解析请求，它就直接告诉用户1.1.1.1，当TTL到期则又会重复 上面的过程。
###域名分级

子域名是个相对的概念，是相对父域名来说的。域名有很多级，中间用点分开。例如中国国家顶级域名CN，所有以 CN 结尾的域名便都是它的子域。例如：www.zzy.cn 便是 zzy.cn 的子域，而 zzy.cn 是 cn 的子域。

“二级域名”：目前有很多用户认为“二级域名”是自己所注册域名的下一级域名，实际上这里所谓的“二级域名”并非真正的“二级”，而应该称为“次级”(相对次级)

例如您注册的域名是abc.cn来说：CN为顶级域，abc.cn为二级域，www.abc.cn、mail.abc.cn、help.zzy.cn为三级域。

还有一些特殊的二级域被用来作顶级域使用，例如：com.cn、net.cn、org.cn、gov.cn（包括地区域名bj.cn、fj.cn等）。那么此时用户所注册的就应该是三级域了，例如114.com.cn。（备注：www.gov.cn实际上是以gov.cn为后缀的www域名，就是说如果您在域名Whois信息查询中输入gov.cn是查询不到注册信息的因为gov.cn是作为顶级域来使用的域名后缀，真正开放注册的是www.gov.cn）。然而当前有很多用户还是习惯地将可以允许用户注册的域名称为顶级域名，而所注册域名的下一级域名称为“二级域名”，其实从严格意义上来讲这是不对的，所以我们前面会说“子域名”、“二级域名”是相对的概念，准确的应该称为“次级域名”。
###域名购买

众所周知，域名是要购买的，国内用域名访问主机大概是要备案的，有些麻烦。所以现在很多人从国外的域名注册商那儿买域名，比如goddady。如果是新手想在国外买域名的话，最好准备一张VISA信用卡，并用paypal来支付（可以省手续费）。goddady现在已经完美支持支付宝了。没什么在国外网站交易的经历，这里就不谈这些了，读者可以自己查。
虽说Godaddy曾支持过SOPA，并且首页放着极其不专业的大胸美女，但是作为域名服务商他做的还不赖，还有他竟然支持支付宝，没有信用卡有时真的很难过。因为伟大英明的GFW的存在，我们买完域名还得多做些事情。

###DNS

流传Godaddy的域名解析服务器被墙掉，导致域名无法访问，不得已需要把域名解析服务迁移到国内比较稳定的服务商处，我们选择DNSPod的服务，他们的产品做得不错，易用、免费：

###最后绑定域名到github page的大致步骤：

1. 首先在DNS服务器上添加A记录，域名商本身提供的DNS服务，或者DNSPod，地址就是Github Pages的服务IP地址：207.97.227.245
    
    刚开始的时候我比较困惑的是，为什么A记录都指向的是同一个IP，GitHub是如何知道应该返回哪        个用户的页面的。其实很简单，秘密就是上面提到的CNAME文件，GitHub应该会缓存所有gh-pages分支中的CNAME文件，用户对域名的请求被定向到GitHub住服务器的IP地址后，再根据用户请求的域名，判断对应哪个gh-pages

2. 如果使用其它DNS服务，需要在域名注册商处修改DNS服务。这里在Godaddy，修改Nameservers为这两个地址：f1g1ns1.dnspod.net、f1g1ns2.dnspod.net。

3. 等待域名解析生效


