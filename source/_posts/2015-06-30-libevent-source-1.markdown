---
layout: post
title: "libevent 源码学习之一"
date: 2015-06-30 14:08
comments: true
categories: 
---


## 简介
libevent是一个轻量级的开源高性能网络库，被很多项目作为底层的网络库，比如memcached、Vomit、Nylon、Netchat等等。
libevent 有几个显著的亮点：

* 事件驱动（event-driven），高性能;
* 轻量级，专注于网络，不如ACE那么臃肿庞大；
* 源代码相当精炼、易读；
* 跨平台，支持Windows、Linux、*BSD和Mac OS；
* 支持多种I/O多路复用技术， epoll、poll、dev/poll、select和kqueue等；
* 支持I/O，定时器和信号等事件；
* 注册事件优先级。


libevent的源码除了涉及网络程序设计方面外，还有很多有用的设计技巧和基础数据结构，比如信息隐藏、函数指针、c语言的多态支持、链表和堆等等。
<!--more-->

### 简单使用

1. 简单的定时
```cpp
    #include <stdio.h> 
    #include <iostream> 
    // libevent头文件 
    #include <event.h> 
    using namespace std; 

    // 定时事件回调函数 
    void onTime(int sock, short event, void *arg) 
    { 
        cout << "Time Out!" << endl; 
       
        struct timeval tv; 
        tv.tv_sec = 1; 
        tv.tv_usec = 0; 
        // 重新添加定时事件（定时事件触发后默认自动删除） 
        event_add((struct event*)arg, &tv); 
    } 

    int main() 
    { 
        // 初始化 
        bevent_init(); 
        struct event evTime; 
        // 设置定时事件 
        evtimer_set(&evTime, onTime, &evTime); 
       
        struct timeval tv; 
        tv.tv_sec = 1; 
        tv.tv_usec = 0; 
        // 添加定时事件 
        event_add(&evTime, &tv); 
       
        // 事件循环 
        event_dispatch(); 
        return 0; 
    }
```

2. TCP服务器：实现监听本机8888端口并输出客户端发送过来的信息
```cpp
    #include <stdio.h> 
    #include <string.h> 
    #include <iostream> 
    #include <sys/socket.h>     
    #include <netinet/in.h>     
    #include <arpa/inet.h>     
    #include <netdb.h> 

    #include <event.h> 
    using namespace std; 

    // 事件base 
    struct event_base* base; 

    // 读事件回调函数 
    void onRead(int iCliFd, short iEvent, void *arg) 
    { 
    int iLen; 
    char buf[1500]; 

    iLen = recv(iCliFd, buf, 1500, 0); 

    if (iLen <= 0) { 
    cout << "Client Close" << endl; 

    // 连接结束(=0)或连接错误(<0)，将事件删除并释放内存空间 
    struct event *pEvRead = (struct event*)arg; 
    event_del(pEvRead); 
    delete pEvRead; 

    close(iCliFd); 
    return; 
    } 

    buf[iLen] = 0; 
    cout << "Client Info:" << buf << endl; 
    } 

    // 连接请求事件回调函数 
    void onAccept(int iSvrFd, short iEvent, void *arg) 
    { 
    int iCliFd; 
    struct sockaddr_in sCliAddr; 

    socklen_t iSinSize = sizeof(sCliAddr); 
    iCliFd = accept(iSvrFd, (struct sockaddr*)&sCliAddr, &iSinSize); 

    // 连接注册为新事件 (EV_PERSIST为事件触发后不默认删除) 
    struct event *pEvRead = new event; 
    event_set(pEvRead, iCliFd, EV_READ|EV_PERSIST, onRead, pEvRead); 
    event_base_set(base, pEvRead); 
    event_add(pEvRead, NULL); 
    } 

    int main() 
    { 

    int iSvrFd;   
    struct sockaddr_in sSvrAddr; 

    memset(&sSvrAddr, 0, sizeof(sSvrAddr));   
    sSvrAddr.sin_family = AF_INET;   
    sSvrAddr.sin_addr.s_addr = inet_addr("127.0.0.1");     
    sSvrAddr.sin_port = htons(8888);    

    // 创建tcpSocket（iSvrFd），监听本机8888端口   
    iSvrFd = socket(AF_INET, SOCK_STREAM, 0);   
    bind(iSvrFd, (struct sockaddr*)&sSvrAddr, sizeof(sSvrAddr));   
    listen(iSvrFd, 10); 

    // 初始化base 
    base = event_base_new(); 

    struct event evListen; 
    // 设置事件 
    event_set(&evListen, iSvrFd, EV_READ|EV_PERSIST, onAccept, NULL); 
    // 设置为base事件 
    event_base_set(base, &evListen); 
    // 添加事件 
    event_add(&evListen, NULL); 

    // 事件循环 
    event_base_dispatch(base); 

    return 0; 
    }
```


## Reactor模式

Reactor模式是编写高性能网络服务器的必备技术之一，它具有如下的优点：

1. 响应快，不必为单个同步时间所阻塞，虽然Reactor本身依然是同步的；
2. 编程相对简单，可以最大程度的避免复杂的多线程及同步问题，并且避免了多线程/进程的切换开销；
3. 可扩展性，可以方便的通过增加Reactor实例个数来充分利用CPU资源；
4. 可复用性，reactor框架本身与具体事件处理逻辑无关，具有很高的复用性；

Reactor模型必备几个组件：事件源、Reactor框架、多路复用机制和事件处理程序。

1. 事件源
Linux上是文件描述符，Windows上就是Socket或者Handle了，这里统一称为“句柄集”；程序在指定的句柄上注册关心的事件，比如I/O事件。

2. event demultiplexer——事件多路分发机制
由操作系统提供的I/O多路复用机制，比如select和epoll。
程序首先将其关心的句柄（事件源）及其事件注册到event demultiplexer上；
当有事件到达时，event demultiplexer会发出通知“在已经注册的句柄集中，一个或多个句柄的事件已经就绪”；
程序收到通知后，就可以在非阻塞的情况下对事件进行处理了。
对应到libevent中，依然是select、poll、epoll等，但是libevent使用结构体eventop进行了封装，以统一的接口来支持这些I/O多路复用机制，达到了对外隐藏底层系统机制的目的。

3. Reactor——反应器
Reactor，是事件管理的接口，内部使用event demultiplexer注册、注销事件；并运行事件循环，当有事件进入“就绪”状态时，调用注册事件的回调函数处理事件。
对应到libevent中，就是event_base结构体。

4. Event Handler——事件处理程序
事件处理程序提供了一组接口，每个接口对应了一种类型的事件，供Reactor在相应的事件发生时调用，执行相应的事件处理。通常它会绑定一个有效的句柄。
对应到libevent中，就是event结构体。

## 源码结构

Libevent的源代码虽然都在一层文件夹下面，但是其代码分类还是相当清晰的，主要可分为头文件、内部使用的头文件、辅助功能函数、日志、libevent框架、对系统I/O多路复用机制的封装、信号管理、定时事件管理、缓冲区管理、基本数据结构和基于libevent的两个实用库等几个部分，有些部分可能就是一个源文件。
源代码中的test部分就不在我们关注的范畴了。

1. 头文件
主要就是event.h：事件宏定义、接口函数声明，主要结构体event的声明；
2. 内部头文件
xxx-internal.h：内部数据结构和函数，对外不可见，以达到信息隐藏的目的；
3. libevent框架
event.c：event整体框架的代码实现；
4. 对系统I/O多路复用机制的封装
epoll.c：对epoll的封装；
select.c：对select的封装；
devpoll.c：对dev/poll的封装;
kqueue.c：对kqueue的封装；
5. 定时事件管理
min-heap.h：其实就是一个以时间作为key的小根堆结构；
6. 信号管理
signal.c：对信号事件的处理；
7. 辅助功能函数
evutil.h 和evutil.c：一些辅助功能函数，包括创建socket pair和一些时间操作函数：加、减和比较等。
8. 日志
log.h和log.c：log日志函数
9. 缓冲区管理
evbuffer.c和buffer.c：libevent对缓冲区的封装；
10. 基本数据结构
compat/sys下的两个源文件：queue.h是libevent基本数据结构的实现，包括链表，双向链表，队列等；_libevent_time.h：一些用于时间操作的结构体定义、函数和宏定义；
11. 实用网络库
http和evdns：是基于libevent实现的http服务器和异步dns查询库；
