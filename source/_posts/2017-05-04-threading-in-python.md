layout: post
title: python 的多线程
date: 2017-05-04 23:43:09
categories:
tags:
---

在开始之前，首先要了解一下python对多线程的支持。

### 虚拟机层面

Python虚拟机使用GIL（Global Interpreter Lock，全局解释器锁）来互斥线程对共享资源的访问，暂时无法利用多处理器的优势。

### 语言层面

在语言层面，Python对多线程提供了很好的支持，Python中多线程相关的模块包括：thread，threading，Queue。可以方便地支持创建线程、互斥锁、信号量、同步等特性。

thread：多线程的底层支持模块，一般不建议使用。
threading：对thread进行了封装，将一些线程的操作对象化，提供下列类：

```
Thread 线程类
Timer与Thread类似，但要等待一段时间后才开始运行
Lock 锁原语
RLock 可重入锁。使单线程可以再次获得已经获得的锁
Condition 条件变量，能让一个线程停下来，等待其他线程满足某个“条件”
Event 通用的条件变量。多个线程可以等待某个事件发生，在事件发生后，所有的线程都被激活
Semaphore为等待锁的线程提供一个类似“等候室”的结构
BoundedSemaphore 与semaphore类似，但不允许超过初始值

```

Queue：实现了多生产者（Producer）、多消费者（Consumer）的队列，支持锁原语，能够在多个线程之间提供很好的同步支持。提供的类：

```
Queue队列
LifoQueue后入先出（LIFO）队列
PriorityQueue 优先队列

```

其中Thread类是你主要的线程类，可以创建进程实例。该类提供的函数包括：

```
getName(self) 返回线程的名字
isAlive(self) 布尔标志，表示这个线程是否还在运行中
isDaemon(self) 返回线程的daemon标志
join(self, timeout=None) 程序挂起，直到线程结束，如果给出timeout，则最多阻塞timeout秒
run(self) 定义线程的功能函数
setDaemon(self, daemonic)  把线程的daemon标志设为daemonic
setName(self, name) 设置线程的名字
start(self) 开始线程执行

```

### 第三方支持

如果你特别在意性能，还可以考虑一些“微线程”的实现：

Stackless Python：Python的一个增强版本，提供了对微线程的支持。微线程是轻量级的线程，在多个线程间切换所需的时间更多，占用资源也更少。

greenlet：是 Stackless 的副产品，其将微线程称为 “tasklet” 。tasklet运行在伪并发中，使用channel进行同步数据交换。而”greenlet”是更加原始的微线程的概念，没有调度。你可以自己构造微线程的调度器，也可以使用greenlet实现高级的控制流。

<!--more-->

## 线程的创建、启动、挂起和退出

如上一节，python的threading.Thread类有一个run方法，用于定义线程的功能函数，可以在自己的线程类中覆盖该方法。而创建自己的线程实例后，通过Thread类的start方法，可以启动该线程，交给python虚拟机进行调度，当该线程获得执行的机会时，就会调用run方法执行线程。让我们开始第一个例子：

```python
encoding: UTF-8
import threading
import time

class MyThread(threading.Thread):
    def run(self):
        for i in range(3):
            time.sleep(1)
            msg = "I'm "+self.name+' @ '+str(i)
            print msg
def test():
    for i in range(5):
        t = MyThread()
        t.start()
if __name__ == '__main__':
    test()

```

执行结果：

```
I'm Thread-1 @ 0
I'm Thread-2 @ 0
I'm Thread-5 @ 0
I'm Thread-3 @ 0
I'm Thread-4 @ 0
I'm Thread-3 @ 1
I'm Thread-4 @ 1
I'm Thread-5 @ 1
I'm Thread-1 @ 1
I'm Thread-2 @ 1
I'm Thread-4 @ 2
I'm Thread-5 @ 2
I'm Thread-2 @ 2
I'm Thread-1 @ 2
I'm Thread-3 @ 2

```

从代码和执行结果我们可以看出，多线程程序的执行顺序是不确定的。当执行到sleep语句时，线程将被阻塞（Blocked），到sleep结束后，线程进入就绪（Runnable）状态，等待调度。而线程调度将自行选择一个线程执行。上面的代码中只能保证每个线程都运行完整个run函数，但是线程的启动顺序、run函数中每次循环的执行顺序都不能确定。

此外需要注意的是：
1.每个线程一定会有一个名字，尽管上面的例子中没有指定线程对象的name，但是python会自动为线程指定一个名字。
2.当线程的run()方法结束时该线程完成。

1.  无法控制线程调度程序，但可以通过别的方式来影响线程调度的方式。

上面的例子只是简单的演示了创建了线程、主动挂起以及退出线程。下一节，将讨论用互斥锁进行线程同步。

## 使用互斥锁同步线程

### 问题的提出

上一节的例子中，每个线程互相独立，相互之间没有任何关系。现在假设这样一个例子：有一个全局的计数num，每个线程获取这个全局的计数，根据num进行一些处理，然后将num加1。很容易写出这样的代码：

```python
encoding: UTF-8
import threading
import time

class MyThread(threading.Thread):
    def run(self):
        global num
        time.sleep(1)
        num = num+1
        msg = self.name+' set num to '+str(num)
        print msg
num = 0
def test():
    for i in range(5):
        t = MyThread()
        t.start()
if __name__ == '__main__':
    test()

```

但是运行结果是不正确的：

```
Thread-5 set num to 2
Thread-3 set num to 3
Thread-2 set num to 5
Thread-1 set num to 5
Thread-4 set num to 4

```

问题产生的原因就是没有控制多个线程对同一资源的访问，对数据造成破坏，使得线程运行的结果不可预期。这种现象称为“线程不安全”。

### 互斥锁同步

上面的例子引出了多线程编程的最常见问题：数据共享。当多个线程都修改某一个共享数据的时候，需要进行同步控制。

线程同步能够保证多个线程安全访问竞争资源，最简单的同步机制是引入互斥锁。互斥锁为资源引入一个状态：锁定/非锁定。某个线程要更改共享数据时，先将其锁定，此时资源的状态为“锁定”，其他线程不能更改；直到该线程释放资源，将资源的状态变成“非锁定”，其他的线程才能再次锁定该资源。互斥锁保证了每次只有一个线程进行写入操作，从而保证了多线程情况下数据的正确性。

threading模块中定义了Lock类，可以方便的处理锁定：

创建锁
```python
mutex = threading.Lock()
```
锁定
```python
mutex.acquire([timeout])
````
释放
```python
mutex.release()
```

其中，锁定方法acquire可以有一个超时时间的可选参数timeout。如果设定了timeout，则在超时后通过返回值可以判断是否得到了锁，从而可以进行一些其他的处理。

使用互斥锁实现上面的例子的代码如下：

```python
import threading
import time

class MyThread(threading.Thread):
    def run(self):
        global num 
        time.sleep(1)

        if mutex.acquire(1):  
            num = num+1
            msg = self.name+' set num to '+str(num)
            print msg
            mutex.release()
num = 0
mutex = threading.Lock()
def test():
    for i in range(5):
        t = MyThread()
        t.start()
if __name__ == '__main__':
    test()
```

运行结果：

```
Thread-3 set num to 1
Thread-4 set num to 2
Thread-5 set num to 3
Thread-2 set num to 4
Thread-1 set num to 5

```

可以看到，加入互斥锁后，运行结果与预期相符。

### 同步阻塞

当一个线程调用锁的acquire()方法获得锁时，锁就进入“locked”状态。每次只有一个线程可以获得锁。如果此时另一个线程试图获得这个锁，该线程就会变为“blocked”状态，称为“同步阻塞”（参见多线程的基本概念）。

直到拥有锁的线程调用锁的release()方法释放锁之后，锁进入“unlocked”状态。线程调度程序从处于同步阻塞状态的线程中选择一个来获得锁，并使得该线程进入运行（running）状态。

互斥锁最基本的内容就是这些，下一节将讨论可重入锁（RLock)和死锁问题。

## 死锁和可重入锁

### 死锁

在线程间共享多个资源的时候，如果两个线程分别占有一部分资源并且同时等待对方的资源，就会造成死锁。尽管死锁很少发生，但一旦发生就会造成应用的停止响应。下面看一个死锁的例子：

```python
encoding: UTF-8
import threading
import time

class MyThread(threading.Thread):
    def do1(self):
        global resA, resB
        if mutexA.acquire():
             msg = self.name+' got resA'
             print msg

             if mutexB.acquire(1):
                 msg = self.name+' got resB'
                 print msg
                 mutexB.release()
             mutexA.release()
    def do2(self):
        global resA, resB
        if mutexB.acquire():
             msg = self.name+' got resB'
             print msg

             if mutexA.acquire(1):
                 msg = self.name+' got resA'
                 print msg
                 mutexA.release()
             mutexB.release()

    def run(self):
        self.do1()
        self.do2()
resA = 0
resB = 0

mutexA = threading.Lock()
mutexB = threading.Lock()

def test():
    for i in range(5):
        t = MyThread()
        t.start()
if __name__ == '__main__':
    test()

```

执行结果：

```
Thread-1 got resA
Thread-1 got resB
Thread-1 got resB
Thread-1 got resA
Thread-2 got resA
Thread-2 got resB
Thread-2 got resB
Thread-2 got resA
Thread-3 got resA
Thread-3 got resB
Thread-3 got resB
Thread-3 got resA
Thread-5 got resA
Thread-5 got resB
Thread-5 got resB
Thread-4 got resA

```

此时进程已经死掉。

### 可重入锁

更简单的死锁情况是一个线程“迭代”请求同一个资源，直接就会造成死锁：

```python
import threading
import time

class MyThread(threading.Thread):
    def run(self):
        global num 
        time.sleep(1)

        if mutex.acquire(1):  
            num = num+1
            msg = self.name+' set num to '+str(num)
            print msg
            mutex.acquire()
            mutex.release()
            mutex.release()
num = 0
mutex = threading.Lock()
def test():
    for i in range(5):
        t = MyThread()
        t.start()
if __name__ == '__main__':
    test()

```

为了支持在同一线程中多次请求同一资源，python提供了“可重入锁”：threading.RLock。RLock内部维护着一个Lock和一个counter变量，counter记录了acquire的次数，从而使得资源可以被多次require。直到一个线程所有的acquire都被release，其他的线程才能获得资源。上面的例子如果使用RLock代替Lock，则不会发生死锁：

```python
import threading
import time

class MyThread(threading.Thread):
    def run(self):
        global num 
        time.sleep(1)

        if mutex.acquire(1):  
            num = num+1
            msg = self.name+' set num to '+str(num)
            print msg
            mutex.acquire()
            mutex.release()
            mutex.release()
num = 0
mutex = threading.RLock()
def test():
    for i in range(5):
        t = MyThread()
        t.start()
if __name__ == '__main__':
    test()

```

执行结果：

```
Thread-1 set num to 1
Thread-3 set num to 2
Thread-2 set num to 3
Thread-5 set num to 4
Thread-4 set num to 5

```

## 条件变量同步

互斥锁是最简单的线程同步机制，Python提供的Condition对象提供了对复杂线程同步问题的支持。Condition被称为条件变量，除了提供与Lock类似的acquire和release方法外，还提供了wait和notify方法。线程首先acquire一个条件变量，然后判断一些条件。如果条件不满足则wait；如果条件满足，进行一些处理改变条件后，通过notify方法通知其他线程，其他处于wait状态的线程接到通知后会重新判断条件。不断的重复这一过程，从而解决复杂的同步问题。

可以认为Condition对象维护了一个锁（Lock/RLock)和一个waiting池。线程通过acquire获得Condition对象，当调用wait方法时，线程会释放Condition内部的锁并进入blocked状态，同时在waiting池中记录这个线程。当调用notify方法时，Condition对象会从waiting池中挑选一个线程，通知其调用acquire方法尝试取到锁。

Condition对象的构造函数可以接受一个Lock/RLock对象作为参数，如果没有指定，则Condition对象会在内部自行创建一个RLock。

除了notify方法外，Condition对象还提供了notifyAll方法，可以通知waiting池中的所有线程尝试acquire内部锁。由于上述机制，处于waiting状态的线程只能通过notify方法唤醒，所以notifyAll的作用在于防止有线程永远处于沉默状态。

演示条件变量同步的经典问题是生产者与消费者问题：假设有一群生产者(Producer)和一群消费者（Consumer）通过一个市场来交互产品。生产者的”策略“是如果市场上剩余的产品少于1000个，那么就生产100个产品放到市场上；而消费者的”策略“是如果市场上剩余产品的数量多余100个，那么就消费3个产品。用Condition解决生产者与消费者问题的代码如下：

```python
import threading
import time

class Producer(threading.Thread):
    def run(self):
        global count
        while True:
            if con.acquire():
                if count > 1000:
                    con.wait()
                else:
                    count = count+100
                    msg = self.name+' produce 100, count=' + str(count)
                    print msg
                    con.notify()
                con.release()
                time.sleep(1)

class Consumer(threading.Thread):
    def run(self):
        global count
        while True:
            if con.acquire():
                if count < 100:
                    con.wait()
                else:
                    count = count-3
                    msg = self.name+' consume 3, count='+str(count)
                    print msg
                    con.notify()
                con.release()
                time.sleep(1)

count = 500
con = threading.Condition()

def test():
    for i in range(2):
        p = Producer()
        p.start()
    for i in range(5):
        c = Consumer()
        c.start()
if __name__ == '__main__':
    test()

```

## 队列同步

前面介绍了互斥锁和条件变量解决线程间的同步问题，并使用条件变量同步机制解决了生产者与消费者问题。

让我们考虑更复杂的一种场景：产品是各不相同的。这时只记录一个数量就不够了，还需要记录每个产品的细节。很容易想到需要用一个容器将这些产品记录下来。

Python的Queue模块中提供了同步的、线程安全的队列类，包括FIFO（先入先出)队列Queue，LIFO（后入先出）队列LifoQueue，和优先级队列PriorityQueue。这些队列都实现了锁原语，能够在多线程中直接使用。可以使用队列来实现线程间的同步。

用FIFO队列实现上述生产者与消费者问题的代码如下：

```python
encoding=utf-8
import threading
import time
from Queue import Queue

class Producer(threading.Thread):
    def run(self):
        global queue
        count = 0
        while True:
            for i in range(100):
                if queue.qsize() > 1000:
                     pass
                else:
                     count = count +1
                     msg = '生成产品'+str(count)
                     queue.put(msg)
                     print msg
            time.sleep(1)

class Consumer(threading.Thread):
    def run(self):
        global queue
        while True:
            for i in range(3):
                if queue.qsize() < 100:
                    pass
                else:
                    msg = self.name + '消费了 '+queue.get()
                    print msg
            time.sleep(1)

queue = Queue()

def test():
    for i in range(500):
        queue.put('初始产品'+str(i))
    for i in range(2):
        p = Producer()
        p.start()
    for i in range(5):
        c = Consumer()
        c.start()
if __name__ == '__main__':
    test()

```

## 线程间通信

很多时候，线程之间会有互相通信的需要。常见的情形是次要线程为主要线程执行特定的任务，在执行过程中需要不断报告执行的进度情况。前面的条件变量同步已经涉及到了线程间的通信（threading.Condition的notify方法）。更通用的方式是使用threading.Event对象。

threading.Event可以使一个线程等待其他线程的通知。其内置了一个标志，初始值为False。线程通过wait()方法进入等待状态，直到另一个线程调用set()方法将内置标志设置为True时，Event通知所有等待状态的线程恢复运行。还可以通过isSet()方法查询Envent对象内置状态的当前值。

举例如下：

```python
import threading
import random
import time

class MyThread(threading.Thread):
    def __init__(self,threadName,event):
        threading.Thread.__init__(self,name=threadName)
        self.threadEvent = event

    def run(self):
        print "%s is ready" % self.name
        self.threadEvent.wait()
        print "%s run!" % self.name

sinal = threading.Event()
for i in range(10):
    t = MyThread(str(i),sinal)
    t.start()

sinal.set()

```

## 线程的合并和后台线程

### 线程的合并

python的Thread类中还提供了join()方法，使得一个线程可以等待另一个线程执行结束后再继续运行。这个方法还可以设定一个timeout参数，避免无休止的等待。因为两个线程顺序完成，看起来象一个线程，所以称为线程的合并。一个例子：

```python
import threading
import random
import time

class MyThread(threading.Thread):

    def run(self):
        wait_time=random.randrange(1,10)
        print "%s will wait %d seconds" % (self.name, wait_time)
        time.sleep(wait_time)
        print "%s finished!" % self.name

if __name__=="__main__":
    threads = []
    for i in range(5):
        t = MyThread()
        t.start()
        threads.append(t)
    print 'main thread is waitting for exit...'        
    for t in threads:
        t.join(1)

    print 'main thread finished!'

```

执行结果：

```
Thread-1 will wait 3 seconds
Thread-2 will wait 4 seconds
Thread-3 will wait 1 seconds
Thread-4 will wait 5 seconds
Thread-5 will wait 3 seconds
main thread is waitting for exit...
Thread-3 finished!
Thread-1 finished!
Thread-5 finished!
main thread finished!
Thread-2 finished!
Thread-4 finished!

```

对于sleep时间过长的线程（这里是2和4），将不被等待。

### 后台线程

默认情况下，主线程在退出时会等待所有子线程的结束。如果希望主线程不等待子线程，而是在退出时自动结束所有的子线程，就需要设置子线程为后台线程(daemon)。方法是通过调用线程类的setDaemon()方法。如下：

```python
import threading
import random
import time

class MyThread(threading.Thread):

    def run(self):
        wait_time=random.randrange(1,10)
        print "%s will wait %d seconds" % (self.name, wait_time)
        time.sleep(wait_time)
        print "%s finished!" % self.name

if __name__=="__main__":
    print 'main thread is waitting for exit...'        

    for i in range(5):
        t = MyThread()
        t.setDaemon(True)
        t.start()

    print 'main thread finished!'

```

执行结果：

```
main thread is waitting for exit...
Thread-1 will wait 3 seconds
Thread-2 will wait 3 seconds
Thread-3 will wait 4 seconds
 Thread-4 will wait 7 seconds
 Thread-5 will wait 7 seconds
main thread finished!

```

可以看出，主线程没有等待子线程的执行，而直接退出。

### 小结

join()方法使得线程可以等待另一个线程的运行，而setDaemon()方法使得线程在结束时不等待子线程。join和setDaemon都可以改变线程之间的运行顺序。

本文转自《心内求法》博客：[http://www.cnblogs.com/holbrook/](http://www.cnblogs.com/holbrook/)
