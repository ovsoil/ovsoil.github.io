---
layout: post
title: "多线程编程之二"
date: 2014-12-11 14:16
comments: true
categories: 
---


## pthread


    int pthread_mutex_init(pthread_mutex_t *restrict mutex, const pthread_mutexattr_t *restrict attr);
    int pthread_mutex_destroy(pthread_mutex_t *mutex);


    int pthread_mutex_lock(pthread_mutex_t *mutex);
    int pthread_mutex_trylock(pthread_mutex_t *mutex);
    int pthread_mutex_unlock(pthread_mutex_t *mutex);

