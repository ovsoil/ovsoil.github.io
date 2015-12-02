---
layout: post
title: "多线程编程之一"
date: 2014-12-10 14:15
comments: true
categories: 
---

在多线程存在的环境中，除了堆栈中的临时数据之外，所有的数据都是共享的。如果我们需要线程之间正确地运行，那么务必需要保证公共数据的执行和计算是正确的。简单一点说，就是保证数据在执行的时候必须是互斥的。否则，如果两个或者多个线程在同一时刻对数据进行了操作，那么后果是不可想象的。

<!--more-->

有什么办法可以保证在某一时刻只有一个线程对数据进行操作呢？四个基本方法：

* 关中断
* 数学互斥方
* 法操作系统提供的互斥方法
* cpu原子操作


1. 关中断

        #include <stdio.h>
        int main()
        {
        	__asm{
        		cli
        		sti
        	}
        	return 1;
        }

2. 数学互斥方法

        unsigned int flag[2] = {0};
        unsigned int turn = 0;
        void process(unsigned int index)
        {
        	flag[index] = 1;
        	turn =  1 - index;

        	while(flag[1 - index] && (turn == (1 - index)));
        	do_something();
        	flag[index] = 0;
        }

操作系统中，上面的算法其实就是Peterson算法，可惜它只能用于两个线程的数据互斥。当然，这个算法还可以推广到更多线程之间的互斥，那就是bakery算法。但是数学算法有两个缺点：

* 占有空间多，两个线程就要flag占两个单位空间，那么n个线程就要n个flag空间，
* 代码编写复杂，考虑的情况比较复杂


3. 操作系统提供的互斥方法

4. cpu原子操作

Windows下

        InterLockedAdd
        InterLockedExchange
        InterLockedCompareExchange
        InterLockedIncrement
        InterLockedDecrement
        InterLockedAnd
        InterLockedOr


###自旋锁

自旋锁是SMP中经常使用到的一个锁。所谓的smp，就是对称多处理器的意思。在工业用的pcb板上面，特别是服务器上面，一个pcb板有多个cpu是很正常的事情。这些cpu相互之间是独立运行的，每一个cpu均有自己的调度队列。然而，这些cpu在内存空间上是共享的。
我们可以看一段Linux 下的的自旋锁代码（kernel 2.6.23，asm-i386/spinlock.h），就可有清晰的认识了，

        static inline void __raw_spin_lock(raw_spinlock_t *lock)
        {
        	asm volatile("\n1:\t"
        		     LOCK_PREFIX " ; decb %0\n\t"
        		     "jns 3f\n"
        		     "2:\t"
        		     "rep;nop\n\t"
        		     "cmpb $0,%0\n\t"
        		     "jle 2b\n\t"
        		     "jmp 1b\n"
        		     "3:\n\t"
        		     : "+m" (lock->slock) : : "memory");
        }

总结：

* 在smp上自旋锁是多cpu互斥访问的基础
* 因为自旋锁是自旋等待的，所以处于临界区的代码应尽可能短
* 上面的LOCK_PREFIX，在x86下面其实就是“lock”，gcc下可以编过

###Windows锁

在windows系统中，系统本身为我们提供了很多锁。通过这些锁的使用，一方面可以加强我们对锁的认识，另外一方面可以提高代码的性能和健壮性。常用的锁以下四种：临界区，互斥量，信号量，event。

1. 临界区

临界区是最简单的一种锁。基本的临界区操作有，

         InitializeCriticalSection
         EnterCriticalSection
         LeaveCriticalSection
         DeleteCriticalSection

如果想要对数据进行互斥操作的话，也很简单，这样做就可以了，

        EnterCriticalSection(/*...*/)
            do_something();
        LeaveCriticalSection(/*...*/)

2. 互斥锁
    互斥锁也是一种锁。和临界区不同的是，它可以被不同进程使用，因为它有名字。同时，获取锁和释放锁的线程必须是同一个线程。常用的互斥锁操作有

        CreateMutex
        OpenMutex
        ReleaseMutex

    那么，怎么用互斥锁进行数据的访问呢，其实不难。

        WaitForSingleObject(/*...*/);
            do_something();
        ReleaseMutex(/*...*/);

3. 信号量
    信号量是使用的最多的一种锁结果，也是最方便的一种锁。围绕着信号量，人们提出了很多数据互斥访问的方案，pv操作就是其中的一种。如果说互斥锁只能对单个资源进行保护，那么信号量可以对多个资源进行保护。同时信号量在解锁的时候，可以被另外一个thread进行解锁操作。目前，常用的信号量操作有，

        CreateSemaphore
        OpenSemaphore
        ReleaseSemaphore
信号量的使用和互斥锁差不多。关键是信号量在初始化的时候需要明确当前资源的数量和信号量的初始状态是什么，

        WaitForSingleObject(/*...*);
            do_something();
        ReleaseSemaphore(/*...*/);

4. event对象
    event对象是windows下面很有趣的一种锁结果。从某种意义上说，它和互斥锁很相近，但是又不一样。因为在thread获得锁的使用权之前，常常需要main线程调用SetEvent设置一把才可以。关键是，在thread结束之前，我们也不清楚当前thread获得event之后执行到哪了。所以使用起来，要特别小心。常用的event操作有，

        CreateEvent
        OpenEvent
        PulseEvent
        ResetEvent
        SetEvent

我们对event的使用习惯于分成main thread和normal thread使用。main thread负责event的设置和操作，而normal thread负责event的等待操作。在CreateEvent的时候，要务必考虑清楚event的初始状态和基本属性。

对于main thread，应该这么做，

        CreateEvent(/*...*/);
        SetEvent(/*...*/);
        WaitForMultiObjects(hThread, /*...*/);
        CloseHandle(/*...*/);

对于normal thread来说，操作比较简单，

        while(1){
            WaitForSingleObject(/*...*/);
        
            /*...*/
        }

总结：

* 关于临界区、互斥区、信号量、event在msdn上均有示例代码
* 一般来说，使用频率上信号量 > 互斥区 > 临界区 > 事件对象
* 信号量可以实现其他三种锁的功能，学习上应有所侧重
* 纸上得来终觉浅，多实践才能掌握它们之间的区别

###用C++特性来保证锁的释放

        class CLock
        {
            CRITICAL_SECTION& cs;
        
        public:
            CLock(CRITICAL_SECTION& lock):cs(lock){
                EnterCriticalSection(&cs);
            }
        
            ~CLock() {
                LeaveCriticalSection(&cs);
            }
        }
        
        class Process
        {
            CRITICAL_SECTION cs;
            /* other data */
        
        public:
            Process(){
                InitializeCriticalSection(&cs);
            }
        
            ~Process() {DeleteCriticalSection(&cs);}
        
            void data_process(){
                CLock lock(cs);
        
                if(/* error happens */){
                    return;
                }
        
                return;
            }
        }

<!-- create time: 2014-12-12 09:35:14  -->
