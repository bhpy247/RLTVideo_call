import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.videocall.videocall"
    compileSdk = 34
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.videocall.videocall"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"

        multiDexEnabled = true
        vectorDrawables.useSupportLibrary = true

    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        debug {
            isDebuggable = true
            isMinifyEnabled = false
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
        }

        release {
            isDebuggable = false
            isMinifyEnabled = true
            isShrinkResources = true

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )

            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }

            buildConfigField("String", "API_BASE_URL", "\"https://api.yourdomain.com\"")
            buildConfigField("Boolean", "ENABLE_LOGGING", "false")

            ndk {
                debugSymbolLevel = "SYMBOL_TABLE"
                abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86_64")
            }
        }

        create("staging") {
            initWith(getByName("release"))
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"

            buildConfigField("String", "API_BASE_URL", "\"https://staging-api.yourdomain.com\"")
            buildConfigField("Boolean", "ENABLE_LOGGING", "true")
        }
    }

    flavorDimensions += "environment"
    productFlavors {
        create("production") {
            dimension = "environment"
            manifestPlaceholders["appLabel"] = "Video Call"
        }
        create("development") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            manifestPlaceholders["appLabel"] = "Video Call Dev"
        }
    }

    buildFeatures {
        buildConfig = true
    }

    lint {
        checkReleaseBuilds = true
        abortOnError = true
        warningsAsErrors = false
        disable += setOf("MissingTranslation", "InvalidPackage")
    }

    packagingOptions {
        resources {
            excludes += setOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/license.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt",
                "META-INF/notice.txt",
                "META-INF/*.kotlin_module"
            )
        }
    }

    bundle {
        language {
            enableSplit = true
        }
        density {
            enableSplit = true
        }
        abi {
            enableSplit = true
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}

tasks.register("checkReleaseSigningConfig") {
    doLast {
        if (!keystorePropertiesFile.exists()) {
            logger.warn("Warning: key.properties file not found. Release builds will use debug signing.")
            logger.warn("Create android/key.properties file for production signing.")
        } else {
            logger.lifecycle("Release signing configuration found.")
        }
    }
}

tasks.whenTaskAdded {
    if (name.contains("Release")) {
        dependsOn("checkReleaseSigningConfig")
    }
}