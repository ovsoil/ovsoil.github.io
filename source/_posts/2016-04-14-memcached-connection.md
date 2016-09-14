layout: post title: memcached的网络框架 date: 2016-04-14 09:41:30 categories:

# tags:

简单的分析一下memcached是如何处理大量并发的连接的。

memcached是个单进程多线程的程序。memcached底层是用的libevent来管理事件的，下面我们就来看看这个libevent的经典应用是如何运转的。其实一开始memcached是个正宗的单线程程序，使用了异步技术后基本能把cpu和网卡的性能发挥到极限了，随着多核cpu的普及，引入多线程也是顺势而为。

memcached的源码结构非常简单，其中线程相关的代码基本都在Thread.c中。简单的说，memcached的众多线程就是个Master-Worker的模型，其中主线程负责接收连接，然后将连接分给各个worker线程，在各个worker线程中完成命令的接收，处理和返回结果。

## memcached连接处理

从main函数开始。

参数t表示设置线程数

    case 't': //此处处理-t参数，设置线程数。
        settings.num_threads = atoi(optarg); 
        if (settings.num_threads <= 0) {
            fprintf(stderr, "Number of threads must be greater than 0\n");
            return 1;
        }
        /* There're other problems when you get above 64 threads.
        In the future we should portably detect # of cores for the
        default.
        */
    if (settings.num_threads > 64) {
        fprintf(stderr, "WARNING: Setting a high number of worker"
        "threads is not recommended.\n"
        " Set this value to the number of cores in"
        " your machine or less.\n");
    }
        break;
    //此处调用线程初始化函数，main_base是主线程的libevent句柄，
    //由于libevent不支持多线程共享句柄，所以每个线程都有一个libevent句柄
    /_ start up worker threads if MT mode _/
    thread_init(settings.num_threads, main_base);

下面，进入线程的初始化环节，在看thread_init这个函数之前，先看几个结构体：

    //worker线程结构体
    typedef struct {
    pthread_t thread_id;        /* 线程ID */
    struct event_base *base;    /* 此线程的libevent句柄 */
    struct event notify_event;  /* 通知事件，主线程通过这个事件通知worker线程有新连接 */
    int notify_receive_fd;      /* 通知事件关联的读fd，这和下面的notify_send_fd是一对管道，具体使用后面讲 */
    int notify_send_fd;         /* 通知事件关联的写fd，后面讲 */
    struct thread_stats stats;  /* 线程相关统计相信 */
    struct conn_queue *new_conn_queue; /* 由主线程分配过来还没来得及处理的连接（客户端）的队列 */
    cache_t *suffix_cache;      /* suffix cache */
    } LIBEVENT_THREAD;
    //这是主线程的结构体，就比较简单了
    //这个结构体的实例只有一个全局的dispatcher_thread
    typedef struct {
    pthread_t thread_id;        /* 主线程ID */
    struct event_base *base;    /* libevent句柄 */
    } LIBEVENT_DISPATCHER_THREAD;

进入线程初始化函数：

    void thread_init(int nthreads, struct event_base *main_base) {
    int         i;
    //先是初始化一堆锁
    //这是主锁，用来同步key-value缓存的存取
    pthread_mutex_init(&cache_lock, NULL);
    //这是缓存状态锁，用来同步memcached的一些统计数据的存取
    pthread_mutex_init(&stats_lock, NULL);
    //这个锁是用来同步init_count（已初始化完的线程数）变量的存取
    pthread_mutex_init(&init_lock, NULL);
    //这是用来通知所有线程都初始化完成的条件变量
    pthread_cond_init(&init_cond, NULL);
    //这个锁是用来同步空闲连接链表的存取
    pthread_mutex_init(&cqi_freelist_lock, NULL);
    cqi_freelist = NULL;
    //分配worker线程结构体内存
    threads = calloc(nthreads, sizeof(LIBEVENT_THREAD));
    if (! threads) {
    perror("Can't allocate thread descriptors");
    exit(1);
    }
    //把主线程先设置好
    dispatcher_thread.base = main_base;
    dispatcher_thread.thread_id = pthread_self();
    //设置所有worker线程与主线程之间的管道
    for (i = 0; i < nthreads; i++) {
    int fds[2];
    if (pipe(fds)) {
    perror("Can't create notify pipe");
    exit(1);
    }
    threads[i].notify_receive_fd = fds[0];
    threads[i].notify_send_fd = fds[1];
    //这个函数进行worker线程的初始化工作
    //比如libevent句柄，连接队列等的初始化
    setup_thread(&threads[i]);
    }
    //这里就是真正调用pthread_create创建线程的地方了
    for (i = 0; i < nthreads; i++) {
    create_worker(worker_libevent, &threads[i]);
    }
    //主线程等所有的worker线程都跑起来了之后再跑后面的代码（接受连接）
    pthread_mutex_lock(&init_lock);
    while (init_count < nthreads) {
    pthread_cond_wait(&init_cond, &init_lock);
    }
    pthread_mutex_unlock(&init_lock);
    }

好了，初始化完成，各个线程（包括主线程）都跑了起来，下面我们看看具体的连接是怎么处理的。

先看主线程，在thread_init返回（所有线程初始化完成）之后，main函数做了一些其他的初始化之后就调用了event_base_loop(main_base, 0);这个函数开始处理网络事件，接受连接了。在此之前，main函数在绑定监听端口的时候就已经把监听socket的事件加到了main_base中了（参看server_socket函数，不多说).
监听事件的回调函数是memcached中所有网络事件公用的回调函数event_handler，而这个event_handler也是基本什么都不干，直接又调用drive_machine，这个函数是由一个大大是switch组成的大状态机。这里就是memcached所有网络事件的处理中枢，我们来看看：

    static void drive_machine(conn *c) {
    bool stop = false;
    int sfd, flags = 1;
    socklen_t addrlen;
    struct sockaddr_storage addr;
    int nreqs = settings.reqs_per_event;
    int res;
    while (!stop) {
    switch(c->state) {
    //这个监听状态只有主线程的监听fd才会有，而主线程也就基本就这么一个状态
    case conn_listening:
    //到这，说明有新连接来了
    //accept新连接
    addrlen = sizeof(addr);
    if ((sfd = accept(c->sfd, (struct sockaddr *)&addr, &addrlen)) == -1) {
    if (errno == EAGAIN || errno == EWOULDBLOCK) {
    /* these are transient, so don't log anything */
    stop = true;
    } else if (errno == EMFILE) {
    if (settings.verbose > 0)
    fprintf(stderr, "Too many open connections\n");
    accept_new_conns(false);
    stop = true;
    } else {
    perror("accept()");
    stop = true;
    }
    break;
    }
    //设置套接字非阻塞
    if ((flags = fcntl(sfd, F_GETFL, 0)) < 0 ||
        fcntl(sfd, F_SETFL, flags | O_NONBLOCK) < 0) {
    perror("setting O_NONBLOCK");
    close(sfd);
    break;
    }
    //将新连接分给worker线程
    dispatch_conn_new(sfd, conn_new_cmd, EV_READ | EV_PERSIST,
    DATA_BUFFER_SIZE, tcp_transport);
    stop = true;
    break;
    //下面是worker线程的一些事件，此处略
    case conn_waiting:
    //...
    case conn_read:
    //...
    }
    return;
    }

接着看dispatch_conn_new这个函数：

    void dispatch_conn_new(int sfd, enum conn_states init_state, int event_flags,
    int read_buffer_size, enum network_transport transport) {
    //分配一个连接队列item，此item将会由主线程塞到worker线程的连接队列中
    CQ_ITEM *item = cqi_new();
    //RR轮询得到这个连接的目标线程
    int tid = (last_thread + 1) % settings.num_threads;
    LIBEVENT_THREAD *thread = threads + tid;
    last_thread = tid;
    //初始化item
    item->sfd = sfd;
    item->init_state = init_state;
    item->event_flags = event_flags;
    item->read_buffer_size = read_buffer_size;
    item->transport = transport;
    //将item塞到worker线程的队列中
    cq_push(thread->new_conn_queue, item);
    MEMCACHED_CONN_DISPATCH(sfd, thread->thread_id);
    //向worker线程的通知写fd中写一个字节，如此notify_receive_fd就会有一个字节可读
    //这样worker线程的notify_event就会收到一个可读的事件
    //memcached就是这样来达到线程间异步通知的目的，很tricky
    if (write(thread->notify_send_fd, "", 1) != 1) {
    perror("Writing to thread notify pipe");
    }
    }

好了，自此主线程处理连接的逻辑基本就没了，下面看看worker线程的相关代码。worker线程初始化完成后将notify_event的libevent事件的回调注册到了thread_libevent_process上，来看看：

    static void thread_libevent_process(int fd, short which, void *arg) {
    LIBEVENT_THREAD *me = arg;
    CQ_ITEM *item;
    char buf[1];
    //将主线程写入的一个字节读掉，一个字节代表一个连接
    if (read(fd, buf, 1) != 1)
    if (settings.verbose > 0)
    fprintf(stderr, "Can't read from libevent pipe\n");
    //将主线程塞到队列中的连接pop出来
    item = cq_pop(me->new_conn_queue);
    if (NULL != item) {
    //初始化新连接，注册事件监听，回调到前面提到的event_handler上
    conn *c = conn_new(item->sfd, item->init_state, item->event_flags,
    item->read_buffer_size, item->transport, me->base);
    if (c == NULL) {
    if (IS_UDP(item->transport)) {
    fprintf(stderr, "Can't listen for events on UDP socket\n");
    exit(1);
    } else {
    if (settings.verbose > 0) {
    fprintf(stderr, "Can't listen for events on fd %d\n",
    item->sfd);
    }
    close(item->sfd);
    }
    } else {
    c->thread = me;
    }
    //回收item
    cqi_free(item);
    }
    }

好了，这样worker线程就多了一个连接了，后面worker线程就是不断的监听notify事件添加连接和客户端连接socket的网络IO事件处理业务了。

memcached的这套多线程libevent机制几乎成了高性能服务器的教学示范。
