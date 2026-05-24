# Flutter ProGuard Rules
# Keep Firebase and Google Play Services classes
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Freezed and JSON serializable models
-keep class * implements _$* { *; }
-keep class * implements $* { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep BLoC pattern classes
-keep class * extends Bloc { *; }
-keep class * extends Cubit { *; }
-keep class * extends Equatable { *; }

# Keep network models
-keep class com.mkhsnw.sakupintar.data.models.** { *; }
-keep class com.mkhsnw.sakupintar.domain.entities.** { *; }

# Keep GoRouter and navigation
-keep class * extends GoRoute { *; }

# Keep TextField and Form related
-keepclassmembers class * extends TextEditingController { *; }

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# Google Play Core / Split Install (direferensi Flutter tapi tidak digunakan)
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# General optimization
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-dontpreverify
-verbose
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*
