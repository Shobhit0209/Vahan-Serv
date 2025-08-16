# Flutter ProGuard rules

# Preserve Flutter framework classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.FlutterEngine { *; }

# Keep all the Dart classes used by Flutter engine
-keep class in.vahanserv.** { *; }

# Google Sign-In
-keep class com.google.android.gms.auth.api.signin.** { *; }
-dontwarn com.google.android.gms.**

# Firebase Auth
-keep class com.google.firebase.auth.** { *; }
-dontwarn com.google.firebase.**

# Firebase Core
-keep class com.google.firebase.** { *; }

# Needed for Firebase phone auth
-keep class com.google.android.gms.internal.** { *; }
-dontwarn com.google.android.gms.internal.**

# Gson (used by many Firebase features internally)
-keep class com.google.gson.** { *; }
-keepattributes *Annotation*

# Glide (in case you use it for images)
-keep public class * implements com.bumptech.glide.module.GlideModule
-keep public class * extends com.bumptech.glide.AppGlideModule
-keep public class * extends com.bumptech.glide.module.LibraryGlideModule
-dontwarn com.bumptech.glide.**

# Prevent obfuscation of Retrofit/Gson model classes (if used)
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**
-dontwarn okhttp3.**

# Prevent obfuscating Kotlin data classes
-keep class kotlin.Metadata
-keepclassmembers class ** {
    @kotlin.Metadata *;
}

# Avoid warnings for lambda & synthetic classes
-dontwarn kotlin.jvm.internal.**

# Optional: If you use Reflection or JSON parsing via class name
-keepnames class * {
    public <init>(...);
}

# General AndroidX rules
-dontwarn androidx.**
-keep class androidx.** { *; }


# Flutter WebView plugin if used
-keep class com.pichillilorenzo.flutter_inappwebview.** { *; }
-dontwarn com.pichillilorenzo.flutter_inappwebview.**

# Required to keep native libraries
-keep class com.google.firebase.** { *; }

# Preserve classes with Firebase annotations
-keep @com.google.firebase.components.Component public class * { *; }
-keep @com.google.firebase.inject.Provider public class * { *; }

# Keep Play Core split install APIs
-keep class com.google.android.play.core.splitinstall.** { *; }
-dontwarn com.google.android.play.core.splitinstall.**

# Keep Play Core tasks APIs
-keep class com.google.android.play.core.tasks.** { *; }
-dontwarn com.google.android.play.core.tasks.**

# Keep Flutter deferred components
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Needed for FlutterPlayStoreSplitApplication
-keep class com.google.android.play.core.splitcompat.SplitCompatApplication { *; }
-dontwarn com.google.android.play.core.splitcompat.**

# Keep Firebase App Check classes
-keep class com.google.firebase.appcheck.** { *; }
-keep class com.google.android.play.core.integrity.** { *; }

# Keep Play Integrity classes
-keep class com.google.android.gms.tasks.** { *; }

# Keep authentication classes
-keep class com.google.firebase.auth.** { *; }

# Keep Gson classes (if using Firebase)
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.** { *; }

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
