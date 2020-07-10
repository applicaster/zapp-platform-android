
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
