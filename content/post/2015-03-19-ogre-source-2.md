---
layout: post
title: "ogre 源码学习之二(几个基本类的实现)"
date: 2015-03-19 22:14:34
comments: true
categories: 
---

几个基本类的实现：
* MemoryAllocator
* 

### MemoryAllocator

    /** A set of categories that indicate the purpose of a chunk of memory
    being allocated. 
    These categories will be provided at allocation time in order to allow
    the allocation policy to vary its behaviour if it wishes. This allows you
    to use a single policy but still have variant behaviour. The level of 
    control it gives you is at a higher level than assigning different 
    policies to different classes, but is the only control you have over
    general allocations that are primitive types.
    */
    enum MemoryCategory
    {
        /// General purpose
        MEMCATEGORY_GENERAL = 0,
        /// Geometry held in main memory
        MEMCATEGORY_GEOMETRY = 1, 
        /// Animation data like tracks, bone matrices
        MEMCATEGORY_ANIMATION = 2, 
        /// Nodes, control data
        MEMCATEGORY_SCENE_CONTROL = 3,
        /// Scene object instances
        MEMCATEGORY_SCENE_OBJECTS = 4,
        /// Other resources
        MEMCATEGORY_RESOURCE = 5,
        /// Scripting
        MEMCATEGORY_SCRIPTING = 6,
        /// Rendersystem structures
        MEMCATEGORY_RENDERSYS = 7,

        
        // sentinel value, do not use 
        MEMCATEGORY_COUNT = 8
    };

    #if OGRE_MEMORY_ALLOCATOR == OGRE_MEMORY_ALLOCATOR_NEDPOOLING

    #  include "OgreMemoryNedPooling.h"
    namespace Ogre
    {
        // configure default allocators based on the options above
        // notice how we're not using the memory categories here but still roughing them out
        // in your allocators you might choose to create different policies per category

        // configurable category, for general malloc
        // notice how we ignore the category here, you could specialise
        template <MemoryCategory Cat> class CategorisedAllocPolicy : public NedPoolingPolicy{};
        template <MemoryCategory Cat, size_t align = 0> class CategorisedAlignAllocPolicy : public NedPoolingAlignedPolicy<align>{};
    }

    #elif OGRE_MEMORY_ALLOCATOR == OGRE_MEMORY_ALLOCATOR_NED

    #  include "OgreMemoryNedAlloc.h"
    namespace Ogre
    {
        // configure default allocators based on the options above
        // notice how we're not using the memory categories here but still roughing them out
        // in your allocators you might choose to create different policies per category

        // configurable category, for general malloc
        // notice how we ignore the category here, you could specialise
        template <MemoryCategory Cat> class CategorisedAllocPolicy : public NedAllocPolicy{};
        template <MemoryCategory Cat, size_t align = 0> class CategorisedAlignAllocPolicy : public NedAlignedAllocPolicy<align>{};
    }

    #elif OGRE_MEMORY_ALLOCATOR == OGRE_MEMORY_ALLOCATOR_STD

    #  include "OgreMemoryStdAlloc.h"
    namespace Ogre
    {
        // configure default allocators based on the options above
        // notice how we're not using the memory categories here but still roughing them out
        // in your allocators you might choose to create different policies per category

        // configurable category, for general malloc
        // notice how we ignore the category here
        template <MemoryCategory Cat> class CategorisedAllocPolicy : public StdAllocPolicy{};
        template <MemoryCategory Cat, size_t align = 0> class CategorisedAlignAllocPolicy : public StdAlignedAllocPolicy<align>{};

        // if you wanted to specialise the allocation per category, here's how it might work:
        // template <> class CategorisedAllocPolicy<MEMCATEGORY_SCENE_OBJECTS> : public YourSceneObjectAllocPolicy{};
        // template <size_t align> class CategorisedAlignAllocPolicy<MEMCATEGORY_SCENE_OBJECTS, align> : public YourSceneObjectAllocPolicy<align>{};
        
        
    }

    #else
        
    // your allocators here?

    #endif


    // Useful shortcuts
    typedef CategorisedAllocPolicy<Ogre::MEMCATEGORY_GENERAL> GeneralAllocPolicy;
    typedef CategorisedAllocPolicy<Ogre::MEMCATEGORY_GEOMETRY> GeometryAllocPolicy;
    typedef CategorisedAllocPolicy<Ogre::MEMCATEGORY_ANIMATION> AnimationAllocPolicy;
    typedef CategorisedAllocPolicy<Ogre::MEMCATEGORY_SCENE_CONTROL> SceneCtlAllocPolicy;
    typedef CategorisedAllocPolicy<Ogre::MEMCATEGORY_SCENE_OBJECTS> SceneObjAllocPolicy;
    typedef CategorisedAllocPolicy<Ogre::MEMCATEGORY_RESOURCE> ResourceAllocPolicy;
    typedef CategorisedAllocPolicy<Ogre::MEMCATEGORY_SCRIPTING> ScriptingAllocPolicy;
    typedef CategorisedAllocPolicy<Ogre::MEMCATEGORY_RENDERSYS> RenderSysAllocPolicy;

    // Now define all the base classes for each allocation
    typedef AllocatedObject<GeneralAllocPolicy> GeneralAllocatedObject;
    typedef AllocatedObject<GeometryAllocPolicy> GeometryAllocatedObject;
    typedef AllocatedObject<AnimationAllocPolicy> AnimationAllocatedObject;
    typedef AllocatedObject<SceneCtlAllocPolicy> SceneCtlAllocatedObject;
    typedef AllocatedObject<SceneObjAllocPolicy> SceneObjAllocatedObject;
    typedef AllocatedObject<ResourceAllocPolicy> ResourceAllocatedObject;
    typedef AllocatedObject<ScriptingAllocPolicy> ScriptingAllocatedObject;
    typedef AllocatedObject<RenderSysAllocPolicy> RenderSysAllocatedObject;


    // Per-class allocators defined here
    // NOTE: small, non-virtual classes should not subclass an allocator
    // the virtual function table could double their size and make them less efficient
    // use primitive or STL allocators / deallocators for those
    typedef ScriptingAllocatedObject    AbstractNodeAlloc;
    typedef AnimationAllocatedObject    AnimableAlloc;
    typedef AnimationAllocatedObject    AnimationAlloc;
    typedef GeneralAllocatedObject      ArchiveAlloc;
    typedef GeometryAllocatedObject     BatchedGeometryAlloc;
    typedef RenderSysAllocatedObject    BufferAlloc;
    typedef GeneralAllocatedObject      CodecAlloc;
    typedef ResourceAllocatedObject     CompositorInstAlloc;
    typedef GeneralAllocatedObject      ConfigAlloc;
    typedef GeneralAllocatedObject      ControllerAlloc;
    typedef GeometryAllocatedObject     DebugGeomAlloc;
    typedef GeneralAllocatedObject      DynLibAlloc;
    typedef GeometryAllocatedObject     EdgeDataAlloc;
    typedef GeneralAllocatedObject      FactoryAlloc;
    typedef SceneObjAllocatedObject     FXAlloc;

