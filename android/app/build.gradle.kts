plugins {
    id("com.android.application")
    // Firebase ke liye ye lazmi hai
    id("com.google.gms.google-services")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // Zee Chat ke liye apna sahi package name (namespace)
    namespace = "com.example.untitled2"

    // Plugins ki requirement ke mutabiq 36 rakha hai taake build fail na ho
    compileSdk = 36

    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.untitled2"

        // --- LOW VERSION FIX START ---
        // 'flutter.minSdkVersion' ki jagah 21 likha hai taake Android 5.0 tak support milay
        minSdk = flutter.minSdkVersion
        targetSdk = 34

        // Firebase ki wajah se method limit cross hoti hai, isliye ye true hona chahiye
        multiDexEnabled = true
        // --- LOW VERSION FIX END ---

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Debug keys use kar rahe hain taake 'flutter run --release' chal sakay
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // MultiDex library jo purane phones ko crash hone se bachati hai
    implementation("androidx.multidex:multidex:2.0.1")
}

flutter {
    source = "../.."
}
