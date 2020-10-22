---
layout: post
title: "ogre 源码学习之一(SampleBrower)"
date: 2015-03-17 22:17:10
comments: true
categories: 
---


SampleBrower

<!--more-->

		#if OGRE_PLATFORM != OGRE_PLATFORM_NACL
				virtual void go(Sample* initialSample = 0)
				{
		#if OGRE_PLATFORM == OGRE_PLATFORM_APPLE_IOS || ((OGRE_PLATFORM == OGRE_PLATFORM_APPLE) && __LP64__)
		            createRoot();

					if (!oneTimeConfig()) return;

		            if (!mFirstRun) mRoot->setRenderSystem(mRoot->getRenderSystemByName(mNextRenderer));

		            setup();

		            if (!mFirstRun) recoverLastSample();
		            else if (initialSample) runSample(initialSample);

		            mRoot->saveConfig();
		#else
					while (!mLastRun)
					{
						mLastRun = true;  // assume this is our last run

						initApp(initialSample);
		        
		                if (mRoot->getRenderSystem() != NULL)
		                {
						    mRoot->startRendering();    // start the render loop
		                }

						closeApp();

						mFirstRun = false;
					}
		#endif
				}
		#endif


