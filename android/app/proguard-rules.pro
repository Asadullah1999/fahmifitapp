# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Hive
-keep class com.hive.** { *; }
-keepclassmembers class ** {
    @com.hive.annotations.HiveType *;
}

# Google ML Kit
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }

# PointyCastle (encryption)
-keep class org.bouncycastle.** { *; }
-keep class org.spongycastle.** { *; }

# RevenueCat
-keep class com.revenuecat.purchases.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-keepclassmembers class **$WhenMappings {
    <fields>;
}
