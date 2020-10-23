package com.applicaster.ui.views;

import android.content.Context;
import android.media.MediaPlayer;
import android.net.Uri;
import android.util.AttributeSet;
import android.view.SurfaceHolder;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.VideoView;

import androidx.annotation.NonNull;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleObserver;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.OnLifecycleEvent;

import com.applicaster.util.APLogger;
import com.applicaster.util.OSUtil;
import com.applicaster.util.ui.PreloaderListener;

import java.lang.ref.WeakReference;

public class ApplicationPreloaderView extends FrameLayout implements LifecycleObserver {

    private PreloaderListener listener;

    private VideoView videoView;

    private MediaPlayer player;

    private WeakReference<LifecycleOwner> lifecycleOwnerWeakReference;

    public ApplicationPreloaderView(Context activity, AttributeSet attrs) {
        super(activity, attrs);
    }

    // As written in https://developer.android.com/reference/android/media/MediaPlayer.html#release()
    // it's a good practice to release the media player, when we're done using it,
    // in particular, when the activity is paused.
    @OnLifecycleEvent(Lifecycle.Event.ON_PAUSE)
    public void releasePlayer() {
        if (videoView != null) {
            videoView.stopPlayback();
        }
        if (player != null) {
            player.release();
            player = null;
        }
    }

    /**
     * Present the intro video
     * Does not acquire the audio focus. Meaning, audio that's being played before presenting the intro, will keep on playing
     *
     * @param introUri       - Uri of the intro video
     * @param lifecycleOwner - life cycle owner, used to release the player when paused.
     */
    public void showIntro(Uri introUri, @NonNull LifecycleOwner lifecycleOwner) {
        lifecycleOwnerWeakReference = new WeakReference<>(lifecycleOwner);
        lifecycleOwner.getLifecycle().addObserver(this);

        videoView = findViewById(OSUtil.getResourceId("preloader_video"));
        videoView.getHolder().addCallback(new SurfaceHolder.Callback() {

            @Override
            public void surfaceCreated(SurfaceHolder holder) {
                player = MediaPlayer.create(videoView.getContext(), introUri);
                if (player == null) {
                    videoView.getHolder().removeCallback(this);
                    listener.onIntroVideoFinished();
                    APLogger.warn(getClass().getSimpleName(), "couldn't play intro video");
                } else {
                    player.setVideoScalingMode(MediaPlayer.VIDEO_SCALING_MODE_SCALE_TO_FIT_WITH_CROPPING);
                    player.setDisplay(holder);
                    player.setOnPreparedListener(mp -> {
                        // VIDEO_SCALING_MODE_SCALE_TO_FIT_WITH_CROPPING does not actually works,
                        // fix it manually by scaling the view
                        int videoHeight = player.getVideoHeight();
                        int videoWidth = player.getVideoWidth();
                        int width = videoView.getWidth();
                        int height = videoView.getHeight();
                        float ratioCorrection = (videoWidth / (float) videoHeight) / (width / (float) height);
                        if (ratioCorrection > 1) {
                            videoView.setScaleX(ratioCorrection);
                        } else if (ratioCorrection < 1) {
                            videoView.setScaleY(1 / ratioCorrection);
                        }
                    });
                    player.setOnCompletionListener(mp -> {
                        videoView.getHolder().removeCallback(this);
                        ApplicationPreloaderView.this.setVisibility(View.GONE);
                        introFinished();
                    });
                    player.setOnErrorListener((mp, what, extra) -> {
                        videoView.getHolder().removeCallback(this);
                        introFinished();
                        return true;
                    });

                    player.start();
                }
            }

            /**
             * Intro finished - completed or encountered an error
             * Actions:
             * - remove the from the life cycle owner observers list
             * - release the player
             * - call the listener's onIntroVideoFinished()
             */
            private void introFinished() {
                if (lifecycleOwnerWeakReference != null) {
                    LifecycleOwner owner = lifecycleOwnerWeakReference.get();
                    if (owner != null) {
                        owner.getLifecycle().removeObserver(ApplicationPreloaderView.this);
                    }
                }
                releasePlayer();
                listener.onIntroVideoFinished();
            }

            @Override
            public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
                // no op
            }

            @Override
            public void surfaceDestroyed(SurfaceHolder holder) {
                // no op
            }
        });

        this.setVisibility(View.VISIBLE);
        videoView.setVisibility(View.VISIBLE);
    }

    public void setListener(PreloaderListener listener) {
        this.listener = listener;
    }

}
