
#-------------------- App level --------------------#

-keep public class com.applicaster.componentsapp.** {
    public <fields>;
    public <methods>;
}

# Without it the debug dialog will not work for example, because the .BuildConfig file will be minified. So NO DELETE.
-keep class **.BuildConfig { *; }

# keep all RN packages
-keep public class * extends com.facebook.react.ReactPackage

# keep all classes with RN methods

-keepclasseswithmembers,includedescriptorclasses class * { @com.facebook.react.bridge.ReactMethod <methods>;}

-keepclassmembers class *  { @com.facebook.react.uimanager.annotations.ReactProp <methods>; }
-keepclassmembers class *  { @com.facebook.react.uimanager.annotations.ReactPropGroup <methods>; }

# keep all the plugins

-keep public class * implements com.applicaster.plugin_manager.PluginI
-keep public class * implements com.applicaster.plugin_manager.GenericPluginI
-keep public class * implements com.applicaster.plugin_manager.crashlog.CrashlogPlugin
-keep public class * implements com.applicaster.plugin_manager.push_plugin.PushContract
-keep public class * implements com.applicaster.plugin_manager.dependencyplugin.base.interfaces.**

## react-native-fast-image

-keep public class com.dylanvann.fastimage.* {*;}
-keep public class com.dylanvann.fastimage.** {*;}
-keep public class * implements com.bumptech.glide.module.GlideModule
-keep public class * extends com.bumptech.glide.module.AppGlideModule
-keep public enum com.bumptech.glide.load.ImageHeaderParser$** {
  **[] $VALUES;
  public *;
}

## react-native-linear-gradient

-keep class com.BV.LinearGradient.** { *; }

## react-native-svg

-keep public class com.horcrux.svg.** {*;}