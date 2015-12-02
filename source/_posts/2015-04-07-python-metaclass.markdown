---
layout: post
title: "Python中的元类(metaclass)"
date: 2015-04-07 13:36
comments: true
categories: 
---

Python中类的概念借鉴于Smalltalk，Python中的*所有东西*都是对象。所以，类同样也是对象，这个对象（类）拥有创建对象（类实例）的能力。伯乐在线上一篇翻译文章[深刻理解Python中的元类(metaclass)](http://blog.jobbole.com/21351/)讲得很详细，这里学习记录一下。

<!--more-->

###Python中，类也是对象，可以对其进行如下操作：

1. 你可以将它赋值给一个变量
2. 你可以拷贝它
3. 你可以为它增加属性
4. 你可以将它作为函数参数进行传递
5. 你可以返回一个类（根据参数返回不同的类）

        >>> print ObjectCreator     # 你可以打印一个类，因为它其实也是一个对象
        <class '__main__.ObjectCreator'>
        >>> def echo(o):
        …       print o
        …
        >>> echo(ObjectCreator)                 # 你可以将类做为参数传给函数
        <class '__main__.ObjectCreator'>
        >>> print hasattr(ObjectCreator, 'new_attribute')
        Fasle
        >>> ObjectCreator.new_attribute = 'foo' #  你可以为类增加属性
        >>> print hasattr(ObjectCreator, 'new_attribute')
        True
        >>> print ObjectCreator.new_attribute
        foo
        >>> ObjectCreatorMirror = ObjectCreator # 你可以将类赋值给一个变量
        >>> print ObjectCreatorMirror()
        <__main__.ObjectCreator object at 0x8997b4c>
        >>> def choose_class(name):
        …       if name == 'foo':
        …           class Foo(object):
        …               pass
        …           return Foo     # 返回的是类，不是类的实例
        …       else:
        …           class Bar(object):
        …               pass
        …           return Bar
        …
        >>> MyClass = choose_class('foo')
        >>> print MyClass              # 函数返回的是类，不是类的实例
        <class '__main__'.Foo>
        >>> print MyClass()            # 你可以通过这个类创建类实例，也就是对象
        <__main__.Foo object at 0x89c6d4c>

当你使用class关键字时，Python解释器自动创建这个对象。但就和Python中的大多数事情一样，Python仍然提供给你手动处理的方法。内建的type函数有一种完全不同的能力，能动态的创建类。type可以接受一个类的描述作为参数，然后返回一个类。

    type(类名, 父类的元组（针对继承的情况，可以为空），包含属性的字典（名称和值）)

例子：

    >>> class MyShinyClass(object):
    …       pass
    可以手动像这样创建：

    >>> MyShinyClass = type('MyShinyClass', (), {})  # 返回一个类对象
    >>> print MyShinyClass
    <class '__main__.MyShinyClass'>
    >>> print MyShinyClass()  #  创建一个该类的实例
    <__main__.MyShinyClass object at 0x8997cec>

元类就是用来创建类的“东西”。函数type实际上是一个元类。type就是Python在背后用来创建所有类的元类。str是用来创建字符串对象的类，而int是用来创建整数对象的类。你可以通过检查__class__属性来看到这一点。

    >>> age = 35
    >>> age.__class__
    <type 'int'>
    >>> name = 'bob'
    >>> name.__class__
    <type 'str'>
    >>> def foo(): pass
    >>>foo.__class__
    <type 'function'>
    >>> class Bar(object): pass
    >>> b = Bar()
    >>> b.__class__
    <class '__main__.Bar'>
对于任何一个__class__的__class__属性又是什么呢？

    >>> a.__class__.__class__
    <type 'type'>
    >>> age.__class__.__class__
    <type 'type'>
    >>> foo.__class__.__class__
    <type 'type'>
    >>> b.__class__.__class__
    <type 'type'>

当你写下如下代码：

    class Foo(Bar):
        pass
Python做了如下的操作：
Foo中有__metaclass__这个属性吗？如果是，Python会在内存中通过__metaclass__创建一个名字为Foo的类对象（我说的是类对象，请紧跟我的思路）。如果Python没有找到__metaclass__，它会继续在Bar（父类）中寻找__metaclass__属性，并尝试做和前面同样的操作。如果Python在任何父类中都找不到__metaclass__，它就会在模块层次中去寻找__metaclass__，并尝试做同样的操作。如果还是找不到__metaclass__,Python就会用内置的type来创建这个类对象。

元类的主要目的就是为了当创建类时能够自动地改变类。通常，你会为API做这样的事情，你希望可以创建符合当前上下文的类。

###为什么要用metaclass类而不是函数?

由于__metaclass__可以接受任何可调用的对象，那为何还要使用类呢，因为很显然使用类会更加复杂啊？这里有好几个原因：

1.  意图会更加清晰。当你读到UpperAttrMetaclass(type)时，你知道接下来要发生什么。
2. 你可以使用OOP编程。元类可以从元类中继承而来，改写父类的方法。元类甚至还可以使用元类。
3.  你可以把代码组织的更好。当你使用元类的时候肯定不会是像我上面举的这种简单场景，通常都是针对比较复杂的问题。将多个方法归总到一个类中会很有帮助，也会使得代码更容易阅读。
4. 你可以使用__new__, __init__以及__call__这样的特殊方法。它们能帮你处理不同的任务。就算通常你可以把所有的东西都在__new__里处理掉，有些人还是觉得用__init__更舒服些。
5. 哇哦，这东西的名字是metaclass，肯定非善类，我要小心！

###究竟为什么要使用元类？

现在回到我们的大主题上来，究竟是为什么你会去使用这样一种容易出错且晦涩的特性？好吧，一般来说，你根本就用不上它：

“元类就是深度的魔法，99%的用户应该根本不必为此操心。如果你想搞清楚究竟是否需要用到元类，那么你就不需要它。那些实际用到元类的人都非常清楚地知道他们需要做什么，而且根本不需要解释为什么要用元类。”  —— Python界的领袖 Tim Peters

元类的主要用途是创建API。一个典型的例子是Django ORM。它允许你像这样定义：

class Person(models.Model):
    name = models.CharField(max_length=30)
    age = models.IntegerField()
但是如果你像这样做的话：

guy  = Person(name='bob', age='35')
print guy.age
这并不会返回一个IntegerField对象，而是会返回一个int，甚至可以直接从数据库中取出数据。这是有可能的，因为models.Model定义了__metaclass__， 并且使用了一些魔法能够将你刚刚定义的简单的Person类转变成对数据库的一个复杂hook。Django框架将这些看起来很复杂的东西通过暴露出一个简单的使用元类的API将其化简，通过这个API重新创建代码，在背后完成真正的工作。

结语
首先，你知道了类其实是能够创建出类实例的对象。好吧，事实上，类本身也是实例，当然，它们是元类的实例。

    >>>class Foo(object): pass
    >>> id(Foo)
    142630324
Python中的一切都是对象，它们要么是类的实例，要么是元类的实例，除了type。type实际上是它自己的元类，在纯Python环境中这可不是你能够做到的，这是通过在实现层面耍一些小手段做到的。其次，元类是很复杂的。对于非常简单的类，你可能不希望通过使用元类来对类做修改。你可以通过其他两种技术来修改类：
1） Monkey patching
2)   class decorators
当你需要动态修改类时，99%的时间里你最好使用上面这两种技术。当然了，其实在99%的时间里你根本就不需要动态修改类。
