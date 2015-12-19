---
layout: post
title: "ogre 源码学习之四(场景管理与渲染队列)"
date: 2015-03-22 21:31:56
comments: true
categories: 
---


从图中我们可以看出render queue是Renderable的集合，这是必然的，因为场景树和渲染队列其实都是对Renderable进行分类，只是分类的标准不同，场景树主要是从空间结构对Renderable进行分类，而渲染队列则是对Renderable从material以及blend(渲染属性)上进行分类。
<!--more-->

我们现看一下RenderPriorityGroup的定义：

    class RenderPriorityGroup
    {
    friend class Ogre::SceneManager;
    
    public:
    typedef std::vector RenderableList;
    // Map on material within each queue group,this is for non-transparent objects only
    typedef std::map MaterialGroupMap;
    // Transparent object list, these are not grouped by material but will be sorted by descending Z
    typedef std::vector TransparentObjectList;

    protected:
    MaterialGroupMap mMaterialGroups;
    TransparentObjectList mTransparentObjects;

    ...
    };

RenderPriorityGroup对Renderable从material上进行了分类，具有相同的Material的Renderalbe分在同一个list中，渲染的时候可以一次性渲染用同一个material的Entity，这样可以减少改变渲染状态的次数，以提高渲染速度（改变渲染状态－pipeline config－对速度影响非常大）。在成员变量中还有一个透明物体的object list，这些物体是需要特别处理的。}

在看一下RenderQueueGroup和RenderQueue的定义：

    class RenderQueueGroup
    {
    public:
    typedef std::map PriorityMap;
    typedef MapIterator PriorityMapIterator;

    protected:
    // Map of RenderPriorityGroup objects
    PriorityMap mPriorityGroups;

    ...
    }

    class _OgreExport RenderQueue
    {
    public:
    typedef std::map< RenderQueueGroupID, RenderQueueGroup* > RenderQueueGroupMap;
    typedef MapIterator QueueGroupIterator;

    protected:
    RenderQueueGroupMap mGroups;
    // The current default queue group
    RenderQueueGroupID mDefaultQueueGroup;

    ...
    }


