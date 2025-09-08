import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
val keystoreProperties = Properties()
if (hasReleaseKeystore) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

android {
    namespace = "com.climbx.climbx_fe"
    compileSdk = 36 // API 36 (flutter_naver_map 요구사항)
    ndkVersion = "27.0.12077973" // 네이버 지도 요구사항

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.climbx.climbx_fe"
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias") 
                    ?: throw GradleException("keyAlias not found in key.properties")
                keyPassword = keystoreProperties.getProperty("keyPassword") 
                    ?: throw GradleException("keyPassword not found in key.properties")
                storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
                    ?: throw GradleException("storeFile not found in key.properties")
                storePassword = keystoreProperties.getProperty("storePassword") 
                    ?: throw GradleException("storePassword not found in key.properties")
            }
        }
    }
    buildTypes {
        release {
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
    testOptions {
        unitTests.isIncludeAndroidResources = true
    }
    lint {
        abortOnError = false
        checkReleaseBuilds = false
        xmlReport = false
        htmlReport = false
        textReport = false
    }
}

flutter {
    source = "../.."
}

// Disable problematic Gradle tasks after evaluation
afterEvaluate {
    // Disable all lint tasks (lintDebug, lintRelease, etc.)
    tasks.matching { it.name.startsWith("lint", ignoreCase = true) }
        .configureEach { enabled = false }

    // Disable all unit test tasks
    tasks.matching { it.name.contains("test", ignoreCase = true) }
        .configureEach { enabled = false }

    // Disable outgoingVariants task
    tasks.matching { it.name.equals("outgoingVariants", ignoreCase = true) }
        .configureEach { enabled = false }
}
