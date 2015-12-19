---
layout: post
title: "GNU toolchain"
date: 2014-07-08 13:28
comments: true
categories: 
---


GNU toolchain:

* gcc
* gdb
* autoconfig
* Makefile

<!--more-->

##gcc
##gdb
##autoconfig

##Makefile

跟我一起写Makefile，这个写的很好，我这只是备忘

###引言
GNU的make工作时的执行步骤入下：（想来其它的make也是类似） 

    1. 读入所有的Makefile。 
    2. 读入被include的其它Makefile。 
    3. 初始化文件中的变量。 
    4. 推导隐晦规则，并分析所有规则。 
    5. 为所有的目标文件创建依赖关系链。 
    6. 根据依赖关系，决定哪些目标要重新生成。 
    7. 执行生成命令。 


    targets : prerequisites 
        command 
        ... 

或是这样

    targets : prerequisites ; command 
            command 
            ... 

一般来说，make会以UNIX的标准Shell，也就是/bin/sh来执行命令。


###通配符

make支持三各通配符：“*”，“?”和“[...]”。这是和Unix的B-Shell是相同的。 
波浪号（“~”）字符在文件名中也有比较特殊的用途。如果是“~/test”，这就表示当前用户的`$HOME`目录下的test目录。而“~hchen/test”则表示用户hchen的宿主目录下的test目录。（这些都是Unix下的小知识了，make也支持）而在Windows或是MS-DOS下，用户没有宿主目录，那么波浪号所指的目录则根据环境变量“HOME”而定。 

通配符代替了你一系列的文件，如“*.c”表示所以后缀为c的文件。一个需要我们注意的是，如果我们的文件名中有通配符，如：“*”，那么可以用转义字符“\”，如“\*”来表示真实的“*”字符，而不是任意长度的字符串。 

    objects = *.o 

上面这个例子，表示了，通符同样可以用在变量中。并不是说[*.o]会展开，不！objects的值就是“*.o”。Makefile中的变量其实就是C/C++中的宏。如果你要让通配符在变量中展开，也就是让objects的值是所有[.o]的文件名的集合，那么，你可以这样： 

    objects := $(wildcard *.o) 


###文件搜索

一些大的工程中，有大量的源文件，我们通常的做法是把这许多的源文件分类，并存放在不同的目录中。然后把路径告诉make，让make在自动去找。 
Makefile文件中的特殊变量“VPATH”就是完成这个功能的，如果没有指明这个变量，make只会在当前的目录中去找寻依赖文件和目标文件。如果定义了这个变量，那么，make就会在当当前目录找不到的情况下，到所指定的目录中去找寻文件了。 

    VPATH = src:../headers 

上面的的定义指定两个目录，“src”和“../headers”，make会按照这个顺序进行搜索。目录由“冒号”分隔。（当然，当前目录永远是最高优先搜索的地方） 
另一个设置文件搜索路径的方法是使用make的“vpath”关键字（注意，它是全小写的），这不是变量，这是一个make的关键字，这和上面提到的那个VPATH变量很类似，但是它更为灵活。它可以指定不同的文件在不同的搜索目录中。这是一个很灵活的功能。它的使用方法有三种： 

    1、vpath <pattern>; <directories>; 

    为符合模式<pattern>;的文件指定搜索目录<directories>;。 

    2、vpath <pattern>; 

    清除符合模式<pattern>;的文件的搜索目录。 

    3、vpath 

    清除所有已被设置好了的文件搜索目录。 

vapth使用方法中的<pattern>;需要包含“%”字符。“%”的意思是匹配零或若干字符，例如，“%.h”表示所有以“.h”结尾的文件。<pattern>;指定了要搜索的文件集，而<directories>;则指定了<pattern>;的文件集的搜索的目录。例如： 

    vpath %.h ../headers 

该语句表示，要求make在“../headers”目录下搜索所有以“.h”结尾的文件。（如果某文件在当前目录没有找到的话） 

我们可以连续地使用vpath语句，以指定不同搜索策略。如果连续的vpath语句中出现了相同的<pattern>;，或是被重复了的<pattern>;，那么，make会按照vpath语句的先后顺序来执行搜索。如： 

    vpath %.c foo 
    vpath %   blish 
    vpath %.c bar 

其表示“.c”结尾的文件，先在“foo”目录，然后是“blish”，最后是“bar”目录。 

    vpath %.c foo:bar 
    vpath %   blish 

而上面的语句则表示“.c”结尾的文件，先在“foo”目录，然后是“bar”目录，最后才是“blish”目录。


###五、伪目标 

最早先的一个例子中，我们提到过一个“clean”的目标，这是一个“伪目标”， 

    clean: 
            rm *.o temp 

正像我们前面例子中的“clean”一样，即然我们生成了许多文件编译文件，我们也应该提供一个清除它们的“目标”以备完整地重编译而用。 （以“make clean”来使用该目标） 

因为，我们并不生成“clean”这个文件。“伪目标”并不是一个文件，只是一个标签，由于“伪目标”不是文件，所以make无法生成它的依赖关系和决定它是否要执行。我们只有通过显示地指明这个“目标”才能让其生效。当然，“伪目标”的取名不能和文件名重名，不然其就失去了“伪目标”的意义了。 

当然，为了避免和文件重名的这种情况，我们可以使用一个特殊的标记“.PHONY”来显示地指明一个目标是“伪目标”，向make说明，不管是否有这个文件，这个目标就是“伪目标”。 

    .PHONY : clean 

只要有这个声明，不管是否有“clean”文件，要运行“clean”这个目标，只有“make clean”这样。于是整个过程可以这样写： 

     .PHONY: clean 
    clean: 
            rm *.o temp 

伪目标一般没有依赖的文件。但是，我们也可以为伪目标指定所依赖的文件。伪目标同样可以作为“默认目标”，只要将其放在第一个。一个示例就是，如果你的Makefile需要一口气生成若干个可执行文件，但你只想简单地敲一个make完事，并且，所有的目标文件都写在一个Makefile中，那么你可以使用“伪目标”这个特性： 

    all : prog1 prog2 prog3 
    .PHONY : all 

    prog1 : prog1.o utils.o 
            cc -o prog1 prog1.o utils.o 

    prog2 : prog2.o 
            cc -o prog2 prog2.o 

    prog3 : prog3.o sort.o utils.o 
            cc -o prog3 prog3.o sort.o utils.o 

我们知道，Makefile中的第一个目标会被作为其默认目标。我们声明了一个“all”的伪目标，其依赖于其它三个目标。由于伪目标的特性是，总是被执行的，所以其依赖的那三个目标就总是不如“all”这个目标新。所以，其它三个目标的规则总是会被决议。也就达到了我们一口气生成多个目标的目的。“.PHONY : all”声明了“all”这个目标为“伪目标”。 

随便提一句，从上面的例子我们可以看出，目标也可以成为依赖。所以，伪目标同样也可成为依赖。看下面的例子： 

    .PHONY: cleanall cleanobj cleandiff 

    cleanall : cleanobj cleandiff 
            rm program 

    cleanobj : 
            rm *.o 

    cleandiff : 
            rm *.diff 

“make clean”将清除所有要被清除的文件。“cleanobj”和“cleandiff”这两个伪目标有点像“子程序”的意思。我们可以输入“make cleanall”和“make cleanobj”和“make cleandiff”命令来达到清除不同种类文件的目的。


###命令


- `@`: 通常，make会打印要执行的命令，若命令前加`@`，该命令不会被打印。另外`make -s(--slient)`禁止命令的显示；`make -n(--just-print)`: 只显示命令，但不执行。
- `;`: 后面的命令在前面命令的基础上执行，中间加`;`，如
        cd dir/;pwd

- `-`: 忽略命令错误。
- 定义命令包
    
        define run-yacc 
        yacc $(firstword $^) 
        mv y.tab.c $@ 
        endef 

###嵌套执行make

- 执行子目录的Makefile

在总控Makefile中：

    subsystem:
        cd subdir && $(MAKE) 
等价于:

    subsystem: 
            $(MAKE) -C subdir 



### 变量

- `$(),${},$$`
- `:=`
- `?=`
- `+=`
- 变量值的替换
        
        foo := a.o b.o c.o 
        bar := $(foo:.o=.c)
    
        foo := a.o b.o c.o 
        bar := $(foo:%.o=%.c) 

- 把变量的值再当成变量
        
        x = y 
        y = z 
        a := $($(x)) 

- `override`:make命令行参数设置的变量会覆盖Makefile中对该变量的赋值，`override`关键字强制赋值。

- 环境变量相当于全局变量，另外上层Makefile中定义的变量可以通过`export`关键字，以系统环境变量的方式传递到下层的Makefile中。


- 目标变量: 在目标冒号后面定义
- 模式变量
-
        
1-5步为第一个阶段，6-7为第二个阶段。第一个阶段中，如果定义的变量被使用了，那么，make会把其展开在使用的位置。但make并不会完全马上展开，make使用的是拖延战术，如果变量出现在依赖关系的规则中，那么仅当这条依赖被决定要使用了，变量才会在其内部展开。



-p 选项，可以打印出make过程中的数据库， 下面研究一下内置的变量和规则。 

变量可分为3类， 
第一类：环境变量， 比较重要的是PATH, PWD 就不一一列举了。 
第二类：内置变量， 比较重要的是cc, CXX, .INCLUDE_DIRS, .DEFAULT_GOAL等 
第三类：自动变量

- `$@`	工作目标的文件名
- `$%`	档案文件成员结构中的文件名
- `$<`	第一个必要条件的文件名
- `$^`	所有必要条件的文件名，用空格隔开
- `$+`	所有必要条件的文件名，用空格隔开，包括重复的文件名
- `$*`	工作目标的主文件名

%D = $(patsubst %/,%,$(dir $%)) 
*D = $(patsubst %/,%,$(dir $*)) 
+D = $(patsubst %/,%,$(dir $+)) 
?D = $(patsubst %/,%,$(dir $?)) 
@D = $(patsubst %/,%,$(dir $@)) 
^D = $(patsubst %/,%,$(dir $^)) 
%F = $(notdir $%) 
*F = $(notdir $*) 
+F = $(notdir $+) 
<F = $(notdir $<) 
?F = $(notdir $?) 
@F = $(notdir $@) 
^F = $(notdir $^) 
 
代表文件（4个） 
$@--目标文件， 
$<--第一个依赖文件。 
$*--代表"茎",例如：文件“dir/a.foo.b”，当目标的模式为“a.%.b ”时,“$* ”的值为“dir/a.foo ” 
$%--当规则的目标文件是一个静态库文件时，代表静态库的一个成员名 
代表文件列表(3个） 
$^--所有的依赖文件， 
$?--所有比目标文件更新的依赖文件列表 
$+--类似“$^”，但是它保留了依赖文件中重复出现的文件 

$(@D) -- 目标的目录部分，文件名部分 
$(@F)  
$(*D) -- 代表"茎"的目录部分,文件名部分 
$(*F)  
$(<D) -- 第一个依赖文件目录部分，文件名部分 
$(<F)  
$(?D) -- 被更新的依赖文件目录部分，文件名部分  
$(?F)  
$(^D) -- 所有依赖文件目录部分，文件名部分 
$(^F)  
$(%D) -- 库文件成员目录部分，文件名部分 
$(%F)  
$(+D) -- 所有依赖的目录部分，文件名部分(可存在重复文件） 
$(+F)  

[ovsoil]:    http://blog.ovsoil.com  "OVSOIL"


