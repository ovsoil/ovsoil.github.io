---
layout: post
title: "Cocos2dx 源码分析之一: 起步(Application)"
date: 2015-04-13 10:37
comments: true
categories: 
---

## 起步

工作需要开发一个简单的2D图形引擎，目前最火的就属cocos2d-x引擎了，开源、跨平台、社区丰富。虽然是游戏引擎，但想来应该有很多可以学习借鉴的地方。所以打算通过源码分析学习一下这个优秀的引擎架构。

<!--more-->

### 环境搭建


### HelloWorld

* main函数

        #include "AppDelegate.h"
        #include "cocos2d.h"
        USING_NS_CC;
        int main(int argc, char *argv[])
        {
            AppDelegate app;
            return Application::getInstance()->run();
        }

    main函数很简单: 1)实例化`AppDelegate`, 运行`Application::getInstance()->run()`。可以发现AppDelegate同样继承自Application，Application继承自ApplicationProtocol类，所以先研究ApplicationProtocol类。

        class CC_DLL ApplicationProtocol
        {
        public:

            // Since WINDOWS and ANDROID are defined as macros, we could not just use these keywords in enumeration(Platform).
            // Therefore, 'OS_' prefix is added to avoid conflicts with the definitions of system macros.
            enum class Platform
            {
                OS_WINDOWS,
                OS_LINUX,
                OS_MAC,
                OS_ANDROID,
                OS_IPHONE,
                OS_IPAD,
                OS_BLACKBERRY,
                OS_NACL,
                OS_EMSCRIPTEN,
                OS_TIZEN,
                OS_WINRT,
                OS_WP8
            };

            virtual ~ApplicationProtocol(){
        #if CC_ENABLE_SCRIPT_BINDING
                ScriptEngineManager::destroyInstance();
        #endif
                PoolManager::destroyInstance();
            }

            virtual bool applicationDidFinishLaunching() = 0;
            virtual void applicationDidEnterBackground() = 0;
            virtual void applicationWillEnterForeground() = 0;
            virtual void setAnimationInterval(double interval) = 0;
            virtual void initGLContextAttrs() {}
            virtual LanguageType getCurrentLanguage() = 0;
            virtual const char * getCurrentLanguageCode() = 0;
            virtual Platform getTargetPlatform() = 0;
            virtual bool openURL(const std::string &url) = 0;
        };

可以看到，ApplicationProtocol是一个抽象类，定义了一个App基本的接口，同时有一个平台类型的枚举`enum class Platform`，然后各个平台再继承该类来实现自己平台的Application类。例如Mac平台的Application类的声明包含在`#if CC_TARGET_PLATFORM == CC_PLATFORM_MAC ... #endif`之间。

* Application类

        int Application::run()
        {
            initGLContextAttrs();
            if(!applicationDidFinishLaunching())
            {
                return 1;
            }
            
            long lastTime = 0L;
            long curTime = 0L;
            
            auto director = Director::getInstance();
            auto glview = director->getOpenGLView();
            
            // Retain glview to avoid glview being released in the while loop
            glview->retain();
            
            while (!glview->windowShouldClose())
            {
                lastTime = getCurrentMillSecond();
                
                director->mainLoop();
                glview->pollEvents();

                curTime = getCurrentMillSecond();
                if (curTime - lastTime < _animationInterval)
                {
                    usleep(static_cast<useconds_t>((_animationInterval - curTime + lastTime)*1000));
                }
            }

            /* Only work on Desktop
            *  Director::mainLoop is really one frame logic
            *  when we want to close the window, we should call Director::end();
            *  then call Director::mainLoop to do release of internal resources
            */
            if (glview->isOpenGLReady())
            {
                director->end();
                director->mainLoop();
            }
            
            glview->release();
            
            return 0;
        }

看看applicationDidFinishLaunching函数里

    bool AppDelegate::applicationDidFinishLaunching() {
        // initialize director
        auto director = Director::getInstance();
        auto glview = director->getOpenGLView();
        if(!glview) {
            glview = GLViewImpl::create("My Game");
            director->setOpenGLView(glview);
        }

        // turn on display FPS
        director->setDisplayStats(true);

        // set FPS. the default value is 1.0/60 if you don't call this
        director->setAnimationInterval(1.0 / 60);

        // create a scene. it's an autorelease object
        auto scene = HelloWorld::createScene();

        // run
        director->runWithScene(scene);

        return true;
    }

每个项目都要有一个自己的App类继承自相应平台的Application调用Application::run方法来实现程序的启动。
