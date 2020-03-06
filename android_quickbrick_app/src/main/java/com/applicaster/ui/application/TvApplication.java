package com.applicaster.ui.application;

import android.content.Context;
import android.content.res.Configuration;

/**
 * QuickBrick applications for TV are using a manipulated density
 * in order to match the same DP size as tvOS and DOM.
 */
public class TvApplication extends BaseApplication {

    @Override
    protected void attachBaseContext(Context base) {
        Configuration configuration = new Configuration(base.getResources().getConfiguration());
        configuration.densityDpi = calculateTvDensity(configuration);

        Context newContext = base.createConfigurationContext(configuration);

        super.attachBaseContext(newContext);
    }

    /**
     * Android TVs report a high density which cause a mismatch vs tvOS and DOM
     * By halving the density, each dp will match a pixel in 1920x1080 devices
     * or 4 pixels in 4k devices (3840x2160).
     * Maybe a few more checks should be done to confirm the original stated density
     * vs the real number of pixels, via base.getResources().getDisplayMetrics()
     * @param configuration fresh base Context from app start, before any manipulations
     * @return density to apply for the TV app.
     */
    private int calculateTvDensity(Configuration configuration) {
        return configuration.densityDpi / 2;
    }
}
