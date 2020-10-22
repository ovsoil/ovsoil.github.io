---
layout: post
title: Erlang 学习01
date: 2016-10-06 22:01:13
categories:
tags:
---

Erlang([`'ə:læŋ`])是一种通用的面向并发的编程语言，它由瑞典电信设备制造商爱立信所辖的CS-Lab开发，目的是创造一种可以应对大规模并发活动的编程语言和运行环境。
Erlang属于多重范型编程语言，涵盖函数式、并发式及分布式。顺序执行的Erlang是一个及早求值, 单次赋值和动态类型的函数式编程语言。
Erlang是一个结构化，动态类型编程语言，内建并行计算支持。最初是由爱立信专门为通信应用设计的，比如控制交换机或者变换协议等，因此非常适 合于构建分布式，实时软并行计算系统。

<!-- more -->


* What is Erlang?
Erlang is a programming language used to build massively scalable soft real-time systems with requirements on high availability. Some of its uses are in telecoms, banking, e-commerce, computer telephony and instant messaging. Erlang's runtime system has built-in support for concurrency, distribution and fault tolerance.

* What is OTP?
OTP is set of Erlang libraries and design principles providing middle-ware to develop these systems. It includes its own distributed database, applications to interface towards other languages, debugging and release handling tools.


* rlang是一门函数式编程语言，具有不可变状态
* Erlang的变量是一次性赋值变量(single-assignment variable)
* 在Erlang里，变量的获得值是一次成功模式匹配操作的结果，=是一个模式匹配操作符
* 在Erlang里，原子被用于表示常量值，原子是全局性的，以小写字母开头，还可以放在单引号内，一个原子的值就是它本身
* 元组用于把一些数量固定的项目归组成单一的实体，用大括号括起，元组会在声明时自动创建，不再使用时则被销毁
* 对于不感兴趣的变量，可以用_ 作为占位符，符号_被称为匿名变量
* 列表用于存放任意数量的元素，用中括号括起，列表的第一个元素称为列表头，剩下的称为列表尾
* Erlang中没有字符串，在Erlang中字符串被表示为一个由整数组成的列表或者一个二进制型，当字符串表示为一个整数列表时，列表里的每个元素都代表了一个Unicode代码点。可以用字符串字面量来创建这样一个列表，字符串字面量是用双引号围起来的一串字符。当shell打印某个列表的值时，只有当列表中所有整数都代表可打印字符才打印字符串字面量。
* f()命令让shell忘记现有所有绑定
* 模块和函数是构建顺序与并行程序的基本单元，模块包含了函数，而函数可以顺序或并行运行
* -module(module_name)是模块声明，位于文件第一行，module_name必须与存放该模块的主文件名相同
* export([func_name/1])是导出声明，Name/N这种记法是指一个带有N个参数的函数Name,N被称为函数的元数(arity)，export的参数是由Name/N组成的一个列表，未导出的函数只能在模块内调用(相当于私有方法)
* 逗号分隔函数调用，数据构造和模式中的参数
* 分号分隔子句，例如函数定义，以及case，if，try…catch，和receive表达式
* 句号分隔函数整体，以及shell里的表达式
* Erlang中用于代表函数的数据类型被称为fun，操作其他函数的函数被称为高阶函数(higher-order function)
* Erlang没有单独的布尔值类型,不过原子true和false具有特殊的意义,可以用来表示布尔值,可用的布尔表达式有四种:not, and, or, xor
* 从R16B版开始,Erlang源代码文件都假定才用UTF-8字符集编码
* Erlang中的数字不是整数就是浮点数,K进制整数使用K#Digits这种写法
* 短路求值:orelse andalso
* type用于类型定义, 如预定义的类型别名:-type term() :: any(). -type term() :: true | false. -type byte() :: 0..255. -type list() :: [any()].
* 在Erlang里创建和销毁进程是非常快速的,进程间发送消息是非常快速的,可以拥有大量进程,进程不共享任何内存,完全独立,唯一的交互方式是消息传递
