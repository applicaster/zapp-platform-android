package com.applicaster.ui.quickbrick;

import androidx.annotation.NonNull;

import android.util.Log;

import com.applicaster.plugin_manager.PluginManager;
import com.applicaster.reactnative.APReactNativeBridgePackage;
import com.applicaster.reactnative.AnalyticsBridgePackage;
import com.applicaster.reactnative.AppDataProviderPackage;
import com.applicaster.reactnative.utils.PackagesExtractor;
import com.facebook.react.ReactPackage;
import com.facebook.react.shell.MainReactPackage;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Flexible utility class to initialize default React Native packages,
 * extract packages from plugins and add extra packages.
 * The class is public and all lists of packages are publicly accessible
 * since this is in no way intended to be used statically across an application -
 * just initialize and manipulate lists of packages at will.
 * <p>
 * Only one single output, besides getters of lists:
 * getAllReactPackages() -> a combined array of all packages lists.
 */
class ReactPackagesManager {
    private final String TAG = getClass().getSimpleName();

    // Setters and getters are left for convenience.
    // since the manager should be used ONCE to produce an output,
    // there is no benefit to keep things private - feel free to set different lists
    // explicitly, disregarding the defaults.
    public List<ReactPackage> getDefaultPackages() {
        return defaultPackages;
    }

    public void setDefaultPackages(List<ReactPackage> defaultPackages) {
        this.defaultPackages = defaultPackages;
    }

    public List<ReactPackage> getPluginPackages() {
        return pluginPackages;
    }

    public void setPluginPackages(List<ReactPackage> pluginPackages) {
        this.pluginPackages = pluginPackages;
    }

    public List<ReactPackage> getExtraPackages() {
        return extraPackages;
    }

    public void setExtraPackages(List<ReactPackage> extraPackages) {
        this.extraPackages = extraPackages;
    }

    private List<ReactPackage> defaultPackages;
    private List<ReactPackage> pluginPackages;
    private List<ReactPackage> extraPackages;

    public ReactPackagesManager() {
        defaultPackages = new ArrayList<>();
        pluginPackages = new ArrayList<>();
        extraPackages = new ArrayList<>();
    }

    /**
     * The class's purpose - get single list containing all packages.
     * Call this after completing initialization and addition of whatever extra packages.
     *
     * @return Unified list of {@link ReactPackage} ready to be served to the ReactInstanceManager
     * via {@link com.facebook.react.ReactInstanceManagerBuilder#addPackage(ReactPackage)}
     */
    @NonNull
    public List<ReactPackage> getAllReactPackages() {
        List<ReactPackage> packages = new ArrayList<>();
        packages.addAll(defaultPackages);
        packages.addAll(pluginPackages);
        packages.addAll(extraPackages);
        return packages;
    }

    /**
     * Adds an instantiated {@link ReactPackage} to the extraPackages list
     *
     * @param reactPackage - Should be instantiated, e.g. new MyReactPackage()
     */
    public void addExtraPackage(ReactPackage reactPackage) {
        extraPackages.add(reactPackage);
    }

    /**
     * Adds default packages used across Applicaster, with the exception of the orientation package.
     * If you choose to not use this method and use the setter instead,
     * make sure to add the required {@link MainReactPackage}.
     * Also, it would be hard not to use the crucial {@link APReactNativeBridgePackage}
     */
    public void initializeDefaultPackages() {
        defaultPackages.add(new MainReactPackage()); // Never a bad idea to have it on the top
        defaultPackages.add(new AppDataProviderPackage()); // This is actually the video player (!!)
        defaultPackages.add(new APReactNativeBridgePackage()); // Crucial for all interactions with native code at app level)
        defaultPackages.add(new AnalyticsBridgePackage());
    }

    /**
     * Gets all initiated/initialized plugins from {@link PluginManager},
     * selects ONLY the react native plugins, and adds to the list any ReactPackage (class name) found.
     * Also removes duplicates, in case multiple plugins refer to the same ReactPackage in the manifest.
     * <p>
     * {@link PackagesExtractor} is in charge of initializing the packages by reflection on the class name.
     * Take care - if the initialization fails, the error is swallowed (default behavior).
     */
    public void initializePackagesFromPlugins() {
        Set<String> allPackageNames = new HashSet<>();

        List<PluginManager.InitiatedPlugin> initiatedPlugins = PluginManager.getInstance().getAllInitiatedPlugins();
        if (initiatedPlugins == null) {
            Log.e(TAG, "no initiated plugins returned from PluginManager");
            return;
        }

        for (PluginManager.InitiatedPlugin pluginInstance : initiatedPlugins) {
            if (pluginInstance.plugin.isRNPlugin) {
                allPackageNames.addAll(pluginInstance.plugin.reactPackages); // also works for empty lists, so this is safe
            }
        }

        if (allPackageNames.isEmpty()) return;

        PackagesExtractor packagesExtractor = new PackagesExtractor();
        pluginPackages = packagesExtractor.getReactPackagesForNames(new ArrayList<>(allPackageNames));
    }
}
