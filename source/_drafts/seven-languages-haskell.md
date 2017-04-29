title: 《七周其语言》之haskell
date: 2017-02-14
tags:
categories:
---

特点：
强类型
纯函数式

固定例子：

1. 阶乘factorial
2. fib
3. 逆序reverse
4. 排列组合permutation
5. all even
6. quick sort
7. 地图作色
8. 路劲算法

1. 惰性的素数序列


```haskell
module Main where
    factorial :: Integer -> Integer
    factorial 0 = 1
    factorial x = x * factorial (x - 1)
```

```haskell
module Main where
    factorial :: Integer -> Integer
    factorial x
        | x > 1 = x * factorial(x - 1)
        | otherwise = 1
```

### 语法(糖):

#### 列表
[1 .. 10]
[1, 3 .. 10]
[10, 9.5 .. 1]
take 5 [1 ..]
take 5 [2, 4 ..]

#### 列表生成式
[x * 2 | x <- [1, 2, 3], x > 1]

#### 匿名函数
(\param1 param2 .. paramn -> function_body)

#### map, filter, foldl, foldr, zip zipWith
map (+ 1) [1 .. 10]
filter odd [1 .. 10]
foldl (\x carryOver -> x + carryOver) 0 [1 .. 10]
foldl (+) [1 .. 10]

#### 柯里化
每个Haskell函数都只有一个参数, 对于多个参数的情况，Haskell绑定一个参数返回函数再绑定下一个参数，这个过程称为柯里化。
大多数情况下，你实际上并不需要考虑它，因为柯里化和非柯里化的函数的结果是相同的。

#### 惰性求值










