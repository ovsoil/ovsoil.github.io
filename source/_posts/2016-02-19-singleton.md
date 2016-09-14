layout: post
title: C++中线程安全且高效的singleton
date: 2016-02-19 13:49:59
categories:
tags:
---


Singleton是一个非常常用的设计模式。几乎所有稍大的程序都会用到它。所以构建一个线程安全，并且高效的singleton很重要。既然要讨论这个主题，我们就先来定义一下我们的需求：

Lazy initialization。只有在第一次使用的时候才需要初始化出一个singleton对象。这使得程序不需要考虑过多顺序耦合的情况。同时也避免了启动时初始化太多不知道什么时候才会用到的东西。
线程安全。多个线程有可能同时调用singleton。如果只需要单线程，那实在没什么需要讨论的。
高效。因为singleton会被反复调用，如果效率低的话浪费太大了。
通用。适合现有的各种平台，以及未来可能出现的平台。
有了这些需求，我们就可以开始讨论如何构造这么一个singleton。下面以C++为基础来解析这个问题。

原始版本
在《设计模式》一书中，给出了singleton的基本结构：

    T& Singleton()
    {
        static T instance;
        return instance;
    }
这个实现是Lazy initialization（需求1），并且高效（需求3）和通用（需求4）。但不是线程安全的（需求2）。因为在C++98中，并没有任何关于多线程的概念。所以也并没有定义如果多个线程同时初始化一个static局部变量会出现什么。

<!--more-->

改进1：加锁
最简单的线程安全改进就是加个锁：

    std::mutex m;

    T& Singleton()
    {
        std::unique_lock lock(m);
        static T instance;
        return instance;
    }
这个实现是Lazy initialization（需求1），并且是线程安全（需求2）和通用（需求4），但它并不高效（需求3）。因为这不但有lock/unlock的开销，还相当于把所有的调用都串行化了。对于频繁调用的情况来说不是个好事。

改进2：双重检查
一个广为人知的改进就是双重检查：

    T* instance = nullptr;
    std::mutex m;

    T& Singleton()
    {
        if (nullptr == instance)
        {
            std::unique_lock lock(m);
            if (nullptr == instance)
            {
                instance = new T;
            }
        }
        return *instance;
    }
这样的双重检查是lazy initialization（需求1），并比上一个实现提高了效率（需求3），因为除了第一次调用的时候需要加锁之外，其他都可以并行判断和返回。但是，这么做真的能线程安全吗（需求2）？这么做真的通用吗（需求2）？

在现代的编译器和CPU上，为了提高性能，真正的执行顺序和高级语言中的已经不一致了。双重检查也不例外。编译器生成的机器码会对内存读写指令进行重新排序，CPU的乱序执行会进一步改变内存读写指令的执行顺序。因为有了这些乱序的存在，instance = new T这一行并不能一次执行完。比如，instance = new T可以分解成3个操作，申请内存、赋值给instance、调用构造函数。后两个操作是以什么方式进行的，只有编译器能决定。如果先赋值给是，再调用构造函数，那么另一个线程同时调用了Singleton()的话，就会发现instance已经有值了，直接使用。但因为这时候还没有在instance上调用构造函数，对象还没被建立出来，这样就会引发严重的问题。

改进3：加上barrier
VC提供了一些intrinsic，以提示编译器和CPU内存读写的顺序。用了这些intrinsic之后，就能保证编译器和CPU不会制造这些混乱。

    T* instance = nullptr;
    std::mutex m;

    T& Singleton()
    {
        if (nullptr == instance)
        {
            std::unique_lock lock(m);
            if (nullptr == instance)
            {
                T* tmp = new T;
                MemoryBarrier();
                instance = tmp;
            }
        }
        return *instance;
    }
有了MemoryBarrier()，就能保证到instance = tmp那行的时候，前面的new T一定已经完成。这样就是线程安全的了（需求2）。同时它也有双重检查的有点，lazy initialization（需求1）和高效（需求3）。那么，通用（需求4）吗？

很遗憾的是，在现有的x86、x64和ARM的内存模型上，这么做是可以的。但在某些很弱的内存模型上，比如已死多时的Alpha，这么做照样不行。未来的平台仍可能出现这样的弱内存模型，所以不得不防。在Alpha上，instance的值被放入寄存器之后，即便它后来被另一个线程赋值了，CPU也不打算再次读取这个地址。所以第二个if仍会通过，以至于new T再次被执行，于是singleton不再是singleton。

有人会问，volatile似乎就是为了解决这样的问题的啊，是不是在这里声明成volatile T* instance就行了？确实，volatile是让编译器生成代码的时候不做假设优化，所以两次读取instance会真的让编译器生成2次读取指令。但Alpha这种情况是CPU偷懒了，即便编译器让它读两次，它都不会就范。所以volatile无法解决这个问题。当然，应该还可以用Alpha的特殊指令来强制CPU再次读取某个变量，但这么做就会让程序不在通用。另外，volatile最多也就是保证那个变量自身不会被错误假设，但无法保证变量之间的读写顺序。尤其是，volatile变量和非volatile变量之间的读写顺序是完全无保证的。

改进4：atomic
Boost引入了atomic库，同时这也被放入C++11的标准库中。它不但提供了原子增减等计算，并且在实现上要求能保证编译器生成代码的读写顺序和CPU执行的读写顺序。也就是说，可以简单地用atomic来实现双重检查singleton。下面用到C++11的代码也可以用boost替换。

    std::atomic<T*> instance;
    std::mutex m;

    T& Singleton()
    {
        if (nullptr == instance)
        {
            std::unique_lock lock(m);
            if (nullptr == instance)
            {
                instance = new T;
            }
        }
        return *instance;
    }
反而变简单了，所有barrier的细节都放到了atomic里，又编译器附带的库来实现。这是第一个能满足上述4个需求的singleton实现。

就到此为止了？不。atomic在判断上还是有开销的，就这么直接使用会让那几行语句都顺序执行。前面提到了，编译器和CPU都倾向于乱序执行，为的是提高效率。都强制了顺序结果会没那么高效了。所以我们还应该能进一步改进。

改进5：更精确地控制
atomic的那些重载操作符因为没法知道用户会如何调用它们，所以只能做非常粗略的假设，也就是在前后都加上了barrier。实际上我们这里需要的只是一个方向的barrier（第一个if那行，读取instance之后加一个读barrier；以及new之后加一个写barrier），而不是两个方向。好在atomic提供了一套精确控制barrier方向的方法，可以用来改进这个问题。

    std::atomic<T*> instance;
    std::mutex m;

    T& Singleton()
    {
        T* tmp = instance.load(std::memory_order_consume);
        if (nullptr == tmp)
        {
            std::unique_lock lock(m);
            tmp = instance.load(std::memory_order_relaxed);
            if (nullptr == tmp)
            {
                instance.store(new X(), std::memory_order_release);
            }
        }
        return *instance;
    }
consume表示后面的读写不会被重排到这次load之前。release表示前面的读写不会被重排到这次store之后。relaxed表示无所谓顺序。这样就保证了在barrier最少的情况下达到目的。当然，这么做的前提仍然是库的实现要对。

改进6：返朴归真
因为编译器的原因，把singleton搞得这么复杂。能不能让编译器做点什么呢？能！C++11标准中特别提到了这种状况：

If control enters the declaration concurrently while the variable is being initialized, the concurrent execution shall wait for completion of the initialization.

换句话说，在多线程同时调用的情况下static只会被初始化一次。也就是说，对于一个符合这个要求的C++11编译器来说，只需要基本结构就可以了。

    T& Singleton()
    {
        static T instance;
        return instance;
    }
是不是有一种返朴归真的感觉？因为编译器保证了static的行为，这里就完全不用担心多线程带来的内存泄漏或重复初始化。所以也不必要用那套反复的方法保证顺序了。当然，在编译器里用的就是全面提到的方法来保证static的行为。

目前实现了这个要求的C++编译器有，VC14（VS2015）和GCC 4.0以上。其他编译器暂时没查到资料。所以安全起见，这里最好用一个#ifdef，对于支持新static的用上改进6的方法，否则用改进5的方法。

总结
好了，目前为止我们得到了两个满足几乎所有singleton需求的实现。从此不必再拘泥于各种强制顺序、低效、不安全、平台相关的singleton了。
