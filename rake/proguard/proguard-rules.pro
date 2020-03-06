-keep class com.applicaster.** { *; }
-keep class com.haarman.listviewanimations.** { *; }
-keep class com.daimajia.** {*;}
-keep class twitter4j.** { *; }
-keep class com.facebook.** { *; }
-keep interface com.facebook.** { *; }
-keep class com.google.** { *; }
-keep class com.mcxiaoke.volley.** { *; }
-keep class twitter4j.** { *; }
-keep class com.facebook.** { *; }
-keep interface com.facebook.** { *; }
-keep class com.flurry.** { *; }
-keep class ocpsoft.prettytime.** { *; }
-keep class **.BuildConfig { *; }

#-------------------- Picasso --------------------#

-keep public class com.squareup.picasso.** {
    public protected <fields>;
    public protected <methods>;
}

#-------------------- Glide --------------------#

-keep public class * implements com.bumptech.glide.module.GlideModule
-keep public enum com.bumptech.glide.load.resource.bitmap.ImageHeaderParser$** {
    **[] $VALUES;
    public *;
}

#-------------------- ListAnimations --------------------#

-keep public class com.nhaarman.listviewanimations.** {
    public protected <fields>;
    public protected <methods>;
}

#-------------------- JustAd SDK --------------------#

-keep public class tv.justad.sdk.** {
    public protected <fields>;
    public protected <methods>;
}

#-------------------- Google IMA --------------------#

-keep public class com.google.ads.interactivemedia.** { *; }

#-------------------- ComScore --------------------#

-keep public class com.comscore.** {
    public <fields>;
    public <methods>;
}

#-------------------- MixPanel --------------------#

-keep public class com.mixpanel.** {
    public <fields>;
    public <methods>;
}

#-------------------- Analytics --------------------#

-keep public class org.spongycastle.** {
    public <fields>;
    public <methods>;
}

#-------------------- Old sections --------------------#

-optimizations !code/simplification/arithmetic
-allowaccessmodification
-repackageclasses 'generic_app'
-keepattributes *Annotation*
-keepattributes InnerClasses
-keepattributes Signature
-keepattributes Exceptions
-dontnote
-ignorewarnings
-dontskipnonpubliclibraryclasses
-dontskipnonpubliclibraryclassmembers

# ########## Android Specific
-keep public class * extends android.app.Activity

-keep public class * extends android.app.Application

-keep public class * extends android.app.Service

-keep public class * extends android.content.BroadcastReceiver

-keep public class * extends android.content.ContentProvider

-keep public class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context,android.util.AttributeSet);
    public <init>(android.content.Context,android.util.AttributeSet,int);
    public void set*(...);
}

-keepclasseswithmembers class * {
    public <init>(android.content.Context,android.util.AttributeSet);
}

-keepclasseswithmembers class * {
    public <init>(android.content.Context,android.util.AttributeSet,int);
}

-keepclassmembers class * extends android.os.Parcelable {
    static android.os.Parcelable$Creator CREATOR;
}

# The following annotations can be specified with classes and with class
# members.
# @Keep specifies not to shrink, optimize, or obfuscate the annotated class
# or class member as an entry point.
-keep @proguard.annotation.Keep class *

-keepclassmembers class * {
    @proguard.annotation.Keep
    <fields>;
    @proguard.annotation.Keep
    <methods>;
}

# The following annotations can only be specified with classes.
# @KeepImplementations and @KeepPublicImplementations specify to keep all,
# resp. all public, implementations or extensions of the annotated class as
# entry points. Note the extension of the java-like syntax, adding annotations
# before the (wild-carded) interface name.
-keep class * extends @proguard.annotation.KeepImplementations *

-keep public class * extends @proguard.annotation.KeepPublicImplementations *

# @KeepApplication specifies to keep the annotated class as an application,
# together with its main method.
-keepclasseswithmembers @proguard.annotation.KeepApplication public class * {
    public static void main(java.lang.String[]);
}

# @KeepClassMembers, @KeepPublicClassMembers, and
# @KeepPublicProtectedClassMembers specify to keep all, all public, resp.
# all public or protected, class members of the annotated class from being
# shrunk, optimized, or obfuscated as entry points.
-keepclassmembers @proguard.annotation.KeepClassMembers class * {
    <fields>;
    <methods>;
}

-keepclassmembers @proguard.annotation.KeepPublicClassMembers class * {
    public <fields>;
    public <methods>;
}

-keepclassmembers @proguard.annotation.KeepPublicProtectedClassMembers class * {
    public protected <fields>;
    public protected <methods>;
}

# @KeepGettersSetters and @KeepPublicGettersSetters specify to keep all, resp.
# all public, getters and setters of the annotated class from being shrunk,
# optimized, or obfuscated as entry points.
-keepclassmembers @proguard.annotation.KeepGettersSetters class * {
    void set*(***);
    void set*(int,***);
    boolean is*();
    boolean is*(int);
    *** get*();
    *** get*(int);
}

-keepclassmembers @proguard.annotation.KeepPublicGettersSetters class * {
    public void set*(***);
    public void set*(int,***);
    public boolean is*();
    public boolean is*(int);
    public *** get*();
    public *** get*(int);
}




# @KeepName specifies not to optimize or obfuscate the annotated class or
# class member as an entry point.
-keep,allowshrinking @proguard.annotation.KeepName class *

-keepclassmembers,allowshrinking class * {
    @proguard.annotation.KeepName
    <fields>;
    @proguard.annotation.KeepName
    <methods>;
}

# @KeepClassMemberNames, @KeepPublicClassMemberNames, and
# @KeepPublicProtectedClassMemberNames specify to keep all, all public, resp.
# all public or protected, class members of the annotated class from being
# optimized or obfuscated as entry points.
-keepclassmembers,allowshrinking @proguard.annotation.KeepClassMemberNames class * {
    <fields>;
    <methods>;
}

-keepclassmembers,allowshrinking @proguard.annotation.KeepPublicClassMemberNames class * {
    public <fields>;
    public <methods>;
}

-keepclassmembers,allowshrinking @proguard.annotation.KeepPublicProtectedClassMemberNames class * {
    public protected <fields>;
    public protected <methods>;
}

