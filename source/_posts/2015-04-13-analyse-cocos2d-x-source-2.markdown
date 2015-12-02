---
layout: post
title: "cocos2d-x 源码分析二：Director"
date: 2015-04-13 12:21
comments: true
categories: 
---


前向声明

```cpp
    /* Forward declarations. */
    class LabelAtlas;
    //class GLView;
    class DirectorDelegate;
    class Node;
    class Scheduler;
    class ActionManager;
    class EventDispatcher;
    class EventCustom;
    class EventListenerCustom;
    class TextureCache;
    class Renderer;
    class Camera;

    class Console;
```

构造/初始化

```
    /** returns a shared instance of the director */
    static Director* getInstance();

    /** @deprecated Use getInstance() instead */
    CC_DEPRECATED_ATTRIBUTE static Director* sharedDirector() { return Director::getInstance(); }
    /**
     * @js ctor
     */
    Director(void);
```


全局成员

```cpp
    static const char *EVENT_PROJECTION_CHANGED;
    static const char* EVENT_AFTER_UPDATE;
    static const char* EVENT_AFTER_VISIT;
    static const char* EVENT_AFTER_DRAW;

    /** @typedef ccDirectorProjection
     Possible OpenGL projections used by director
     */
    enum class Projection
    {
        /// sets a 2D projection (orthogonal projection)
        _2D,
        
        /// sets a 3D projection with a fovy=60, znear=0.5f and zfar=1500.
        _3D,
        
        /// it calls "updateProjection" on the projection delegate.
        CUSTOM,
        
        /// Default projection is 3D projection
        DEFAULT = _3D,
    };
    
```

。
。
坐标操作

场景管理

内存

opengl

mainloop

other

详细分析几个方法：
`getInstance()`:

```cpp
    Director* Director::getInstance()
    {
        if (!s_SharedDirector)
        {
            s_SharedDirector = new (std::nothrow) DisplayLinkDirector();
            CCASSERT(s_SharedDirector, "FATAL: Not enough memory");
            s_SharedDirector->init();
        }

        return s_SharedDirector;
    }
```
```cpp
    bool Director::init(void)
    {
        setDefaultValues();

        // scenes
        _runningScene = nullptr;
        _nextScene = nullptr;

        _notificationNode = nullptr;

        _scenesStack.reserve(15);

        // FPS
        _accumDt = 0.0f;
        _frameRate = 0.0f;
        _FPSLabel = _drawnBatchesLabel = _drawnVerticesLabel = nullptr;
        _totalFrames = 0;
        _lastUpdate = new struct timeval;
        _secondsPerFrame = 1.0f;

        // paused ?
        _paused = false;

        // purge ?
        _purgeDirectorInNextLoop = false;
        
        // restart ?
        _restartDirectorInNextLoop = false;

        _winSizeInPoints = Size::ZERO;

        _openGLView = nullptr;

        _contentScaleFactor = 1.0f;

        // scheduler
        _scheduler = new (std::nothrow) Scheduler();
        // action manager
        _actionManager = new (std::nothrow) ActionManager();
        _scheduler->scheduleUpdate(_actionManager, Scheduler::PRIORITY_SYSTEM, false);

        _eventDispatcher = new (std::nothrow) EventDispatcher();
        _eventAfterDraw = new (std::nothrow) EventCustom(EVENT_AFTER_DRAW);
        _eventAfterDraw->setUserData(this);
        _eventAfterVisit = new (std::nothrow) EventCustom(EVENT_AFTER_VISIT);
        _eventAfterVisit->setUserData(this);
        _eventAfterUpdate = new (std::nothrow) EventCustom(EVENT_AFTER_UPDATE);
        _eventAfterUpdate->setUserData(this);
        _eventProjectionChanged = new (std::nothrow) EventCustom(EVENT_PROJECTION_CHANGED);
        _eventProjectionChanged->setUserData(this);


        //init TextureCache
        initTextureCache();
        initMatrixStack();

        _renderer = new (std::nothrow) Renderer;

        _console = new (std::nothrow) Console;

        return true;
    }
```

```cpp
    /** 
     @brief DisplayLinkDirector is a Director that synchronizes timers with the refresh rate of the display.
     
     Features and Limitations:
      - Scheduled timers & drawing are synchronizes with the refresh rate of the display
      - Only supports animation intervals of 1/60 1/30 & 1/15
     
     @since v0.8.2
     */
    class DisplayLinkDirector : public Director
    {
    public:
        DisplayLinkDirector() 
            : _invalid(false)
        {}
        virtual ~DisplayLinkDirector(){}

        //
        // Overrides
        //
        virtual void mainLoop() override;
        virtual void setAnimationInterval(double value) override;
        virtual void startAnimation() override;
        virtual void stopAnimation() override;

    protected:
        bool _invalid;
    };
```

```cpp
void DisplayLinkDirector::mainLoop()
{
    if (_purgeDirectorInNextLoop)
    {
        _purgeDirectorInNextLoop = false;
        purgeDirector();
    }
    else if (_restartDirectorInNextLoop)
    {
        _restartDirectorInNextLoop = false;
        restartDirector();
    }
    else if (! _invalid)
    {
        drawScene();
     
        // release the objects
        PoolManager::getInstance()->getCurrentPool()->clear();
    }
}
```

```cpp
    // Draw the Scene
    void Director::drawScene()
    {
        // calculate "global" dt
        calculateDeltaTime();
        
        if (_openGLView)
        {
            _openGLView->pollEvents();
        }

        //tick before glClear: issue #533
        if (! _paused)
        {
            _scheduler->update(_deltaTime);
            _eventDispatcher->dispatchEvent(_eventAfterUpdate);
        }

        _renderer->clear();

        /* to avoid flickr, nextScene MUST be here: after tick and before draw.
         * FIXME: Which bug is this one. It seems that it can't be reproduced with v0.9
         */
        if (_nextScene)
        {
            setNextScene();
        }

        pushMatrix(MATRIX_STACK_TYPE::MATRIX_STACK_MODELVIEW);
        
        if (_runningScene)
        {
#if CC_USE_PHYSICS
            auto physicsWorld = _runningScene->getPhysicsWorld();
            if (physicsWorld && physicsWorld->isAutoStep())
            {
                physicsWorld->update(_deltaTime, false);
            }
#endif
            //clear draw stats
            _renderer->clearDrawStats();
            
            //render the scene
            _runningScene->render(_renderer);
            
            _eventDispatcher->dispatchEvent(_eventAfterVisit);
#if CC_USE_PHYSICS
            if(physicsWorld)
            {
                physicsWorld->_updateBodyTransform = false;
            }
#endif
        }

        // draw the notifications node
        if (_notificationNode)
        {
            _notificationNode->visit(_renderer, Mat4::IDENTITY, 0);
        }

        if (_displayStats)
        {
            showStats();
        }
        _renderer->render();

        _eventDispatcher->dispatchEvent(_eventAfterDraw);

        popMatrix(MATRIX_STACK_TYPE::MATRIX_STACK_MODELVIEW);

        _totalFrames++;

        // swap buffers
        if (_openGLView)
        {
            _openGLView->swapBuffers();
        }

        if (_displayStats)
        {
            calculateMPF();
        }
    }
```
