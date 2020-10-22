---
layout: post
title: "SQL学习之一"
date: 2015-03-31 09:08
comments: true
categories: 
---


SQL 分为两个部分：数据操作语言 (DML) 和 数据定义语言 (DDL)。

查询和更新指令构成了 SQL 的 DML 部分：

* SELECT - 从数据库表中获取数据
* UPDATE - 更新数据库表中的数据
* DELETE - 从数据库表中删除数据
* INSERT INTO - 向数据库表中插入数据

SQL 的数据定义语言 (DDL) 部分使我们有能力创建或删除表格。我们也可以定义索引（键），规定表之间的链接，以及施加表间的约束。

* CREATE DATABASE - 创建新数据库
* ALTER DATABASE - 修改数据库
* CREATE TABLE - 创建新表
* ALTER TABLE - 变更（改变）数据库表
* DROP TABLE - 删除表
* CREATE INDEX - 创建索引（搜索键）
* DROP INDEX - 删除索引

<!--more-->


###语句

* SELECT

        SELECT 列名称 FROM 表名称
        SELECT * FROM 表名称
        SELECT DISTINCT 列名称 FROM 表名称
        SELECT 列名称 FROM 表名称 WHERE 列 运算符 值
        SELECT Company, OrderNumber FROM Orders ORDER BY Company
        SELECT Company, OrderNumber FROM Orders ORDER BY Company DESC

        注释：SQL 语句对大小写不敏感。SELECT 等效于 select。


下面的运算符可在 WHERE 子句中使用：

| 操作符| 描述  | 
| :----:| :----:| 
|=      |等于   |
|<>	    |不等于 |
|>	    |大于   |
|<	    |小于   |
|>=	    |大于等于|
|<=	    |小于等于|
|BETWEEN|在某个范围内|
|LIKE	|搜索某种模式|

注释：在某些版本的 SQL 中，操作符 <> 可以写为 !=。

由 SQL 查询程序获得的结果被存放在一个结果集中。大多数数据库软件系统都允许使用编程函数在结果集中进行导航，比如：Move-To-First-Record、Get-Record-Content、Move-To-Next-Record 等等。

* INSERT INTO 语句

        INSERT INTO 表名称 VALUES (值1, 值2,....)
        我们也可以指定所要插入数据的列：        
        INSERT INTO table_name (列1, 列2,...) VALUES (值1, 值2,....)

* Update 语句

        UPDATE 表名称 SET 列名称 = 新值 WHERE 列名称 = 某值
* DELETE 语句
    
        DELETE FROM 表名称 WHERE 列名称 = 值





