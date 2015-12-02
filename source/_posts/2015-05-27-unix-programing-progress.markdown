---
layout: post
title: "Unix编程之进程"
date: 2015-05-27 15:25
comments: true
categories: 
---


### fork

    #inlclude <unistd.h>
    pid_t fork(void)

fork 子进程是父进程的副本，获得数据空间、堆和栈的副本，但共享正文段。共享打开文、用户ID、回话ID、工作目录、、、等等。


### vfork

vfork 与 fork一样会创建一个子进程，但是它不将父进程的地址空间完全复制到子进程中，因为子进程会立即调用exec（或exit）。（写时复制技术）。
另一个区别是，vfork保证子进程先运行，在它调用exec或者exit之后父进程才可能被调度运行。（如果调用这两个函数之前子进程依赖于父进程的进一步动作，就会导致死锁）


### 进程终止

5种正常终止：
return
exit
_exit _Exit
最后一个线程执行return，该进程以终止状态0返回。
最后一个线程调用pthread_exit，该进程以终止状态0返回。

3种异常终止：
调用abort，它产生SIGARBT信号。
当进程接收到某些信号，信号可以由进程自身、其他进程、内核产生。
最后一个进程对“取消”（cancellation）请求做出响应。

wait
waitid


### race condition



