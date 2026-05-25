plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Google services plugin — reads google-services.json for OAuth/Firebase config
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.batchit"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        create("batchitDebug") {
            storeFile = file("${System.getProperty("user.home")}/.android/batchit-debug.keystore")
            storePassword = "batchit123"
            keyAlias = "batchit"
            keyPassword = "batchit123"
        }
    }

    defaultConfig {
        applicationId = "com.example.batchit"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("batchitDebug")
        }
        release {
            signingConfig = signingConfigs.getByName("batchitDebug")
        }
    }
}

flutter {
    source = "../.."
}
