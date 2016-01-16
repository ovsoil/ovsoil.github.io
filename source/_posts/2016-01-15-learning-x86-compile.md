layout: post
title: X86 汇编备忘
date: 2016-01-15 11:01:59
categories:
tags:
---

x86汇编语言主要有两个语法分支: AT&T和Intel。我们平常接触到的GNU系的工具（包括GCC，OBJDUMP等）都是使用AT&T语法

|       |AT&T   |	Intel	| 注释|
|:-----:|:-----:|:------:|:---:|
|寄存器    |%eax   |eax    |   |
|立即数    |$5     |	5     |	  |
|指令后缀	  |movl   |mov    |操作数长度4|
|操作数方向 |movl $5, %eax|	mov eax,5| |
|寻址1	  |var    |	[var]	|   寄存器直接寻址|
|寻址2   |0x8(%eax)|	[eax + 0x8]|段+偏移寻址|
|寻址3	   |%segreg:disp(base,index,scale)|	segreg:[base+index*scale+disp]|间接寻址|

<!--more-->

* 通用寄存器

>32位x86架构的CPU有8个通用寄存器:
AX: Accumulator register
CX: Counter register
DX: Data register
BX: Base register
SP: Stack pointer register，指向栈顶。
BP: Stack base pointer register，指向当前stack frame的底部。
SI: Source index register
DI: Destination index register


* 除法：
16位除以8位：被除数AX；商AL；余数AH；
32位除以16位：被除数DX:AX；商AX；余数DX；

* 传送指令：
rep(重复前缀) movsb/movsw 
DS:SI -> ES:DI
CX传送次数，Flags寄存器第10位（DF)表示方向标志，
cld: DF设为0，正方向传递，从低地址到高地址
std: DF设为1，反方向传递，从搞地址到低地址

* 循环：
`loop 标号`
处理器执行该指令时做两件事：
* 将寄存器CX的内容减一
* 如果CX的内容不为0，转移到指定的标号处执行，否则顺序执行之后的指令。







