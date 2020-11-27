package com.applicaster.ui.loaders

import android.content.Context
import com.applicaster.ui.activities.MainActivity
import com.applicaster.ui.loaders.MainActivityPreloadSequence.configure
import com.applicaster.util.APLogger
import com.applicaster.zapp.quickbrick.loader.DataLoader
import io.reactivex.Completable
import io.reactivex.schedulers.Schedulers
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import org.powermock.api.mockito.PowerMockito
import org.powermock.core.classloader.annotations.PrepareForTest
import org.powermock.modules.junit4.PowerMockRunner

@RunWith(PowerMockRunner::class)
@PrepareForTest(MainActivity::class, DataLoader::class, APLogger::class)
class MainActivityPreloadSequenceTest {
    @Test
    fun reachableTest() {
        val activity = PowerMockito.mock(MainActivity::class.java)
        val context = PowerMockito.mock(Context::class.java)

        PowerMockito.mockStatic(DataLoader::class.java)
        PowerMockito.mockStatic(APLogger::class.java)

        // fake context
        PowerMockito.`when`(activity.applicationContext).thenReturn(context)

        //actual steps
        PowerMockito.`when`(activity.playVideoIntroIfPresent()).thenReturn(Completable.complete())
        PowerMockito.`when`(activity.executeHooks(false)).thenReturn(Completable.complete())
        PowerMockito.`when`(DataLoader.initialize(activity.applicationContext)).thenReturn(Completable.complete())
        PowerMockito.`when`(activity.executeHooks(true)).thenReturn(Completable.complete())
        PowerMockito.`when`(activity.initializeUILayer()).thenReturn(Completable.complete())
        PowerMockito.`when`(activity.showUI()).thenReturn(Completable.complete())

        val preloader = configure(activity, Schedulers.trampoline())
        preloader.run()
        Assert.assertTrue(preloader.complete())
    }
}