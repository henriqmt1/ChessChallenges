import java.util.Base64

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

fun decodedDartDefines(): Map<String, String> {
    val encodedDefines = providers.gradleProperty("dart-defines").orNull
        ?: return emptyMap()

    return encodedDefines
        .split(',')
        .filter { it.isNotBlank() }
        .mapNotNull { encoded ->
            val decoded = String(Base64.getDecoder().decode(encoded))
            val parts = decoded.split('=', limit = 2)
            if (parts.size == 2) {
                parts[0] to parts[1]
            } else {
                null
            }
        }
        .toMap()
}

val dartDefines = decodedDartDefines()

fun buildValue(name: String, defaultValue: String): String =
    dartDefines[name] ?: System.getenv(name) ?: defaultValue

android {
    namespace = "com.henriquemarinhoteixeira.chesschalenges"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.henriquemarinhoteixeira.chesschalenges"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["admobApplicationId"] = buildValue(
            "ADMOB_APP_ID_ANDROID",
            "ca-app-pub-1922989446248337~2737556548",
        )
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
