---
layout: post
title: 虚拟软盘
date: 2016-01-08 20:23:35
categories:
tags:
---



3.5寸1.44M软盘的结构：2面、80道/面、18扇区/道、512字节/扇区。
所以其扇区总数 = 2 * 80 * 18 = 2880；存储容量 = 1474560B

1. 创建虚拟软盘镜像文件：`dd if=/dev/zero of=floppy.img bs=512 count=2880`
2. 创建mbr文件：`dd if=/dev/sdX of=mbr.img bs=512 count=1`
3. 修改mbr文件：
    * 二进制打开文件：`vim -b mbr.img`
    * 转换为16进制编辑模式：`:%!xxd`
    * 确认第512字节是否是0x55aa，之后编辑内容
    * 转换回二进制：`:%!xxd -r`
    * 保存退出：`:wq`

4. 替换软盘前512字节，加上`conv=notrunc`选项即可只替换部分而不覆盖输出文件：
    `dd if=mbr.img of=floppy.img conv=notrunc bs=512 count=1` 

该`floppy.img`文件即可作为虚拟机的启动介质，用以测试mbr修改。在parallels desktop虚拟机中测试通过。


