import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.ybm.your_budget_manager"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.ybm.your_budget_manager"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keyAliasVal = keystoreProperties.getProperty("keyAlias")
            val keyPasswordVal = keystoreProperties.getProperty("keyPassword")
            val storeFileVal = keystoreProperties.getProperty("storeFile")
            val storePasswordVal = keystoreProperties.getProperty("storePassword")

            if (storeFileVal != null) {
                val directFile = file(storeFileVal)
                val projectFile = rootProject.file(storeFileVal)
                if (directFile.exists()) {
                    storeFile = directFile
                    keyAlias = keyAliasVal
                    keyPassword = keyPasswordVal
                    storePassword = storePasswordVal
                } else if (projectFile.exists()) {
                    storeFile = projectFile
                    keyAlias = keyAliasVal
                    keyPassword = keyPasswordVal
                    storePassword = storePasswordVal
                }
            }
        }
    }

    buildTypes {
        release {
            val releaseConfig = signingConfigs.getByName("release")
            val hasValidStore = releaseConfig.storeFile != null && releaseConfig.storeFile!!.exists()
            val hasValidCredentials = !releaseConfig.keyAlias.isNullOrBlank() &&
                !releaseConfig.keyPassword.isNullOrBlank() &&
                !releaseConfig.storePassword.isNullOrBlank()

            if (hasValidStore && hasValidCredentials) {
                signingConfig = releaseConfig
            } else {
                signingConfig = null

                gradle.taskGraph.whenReady {
                    val isReleaseTask = allTasks.any { task ->
                        task.name.contains("Release", ignoreCase = true) &&
                        (task.name.startsWith("assemble") ||
                         task.name.startsWith("bundle") ||
                         task.name.startsWith("package") ||
                         task.name.startsWith("build"))
                    }

                    if (isReleaseTask) {
                        val missingDetails = mutableListOf<String>()
                        if (!keystorePropertiesFile.exists()) {
                            missingDetails.add("key.properties file not found at: ${keystorePropertiesFile.absolutePath}")
                        }
                        if (releaseConfig.storeFile == null || !releaseConfig.storeFile!!.exists()) {
                            val path = keystoreProperties.getProperty("storeFile") ?: "not specified"
                            missingDetails.add("Keystore file '$path' does not exist")
                        }
                        if (releaseConfig.keyAlias.isNullOrBlank()) missingDetails.add("keyAlias is missing")
                        if (releaseConfig.keyPassword.isNullOrBlank()) missingDetails.add("keyPassword is missing")
                        if (releaseConfig.storePassword.isNullOrBlank()) missingDetails.add("storePassword is missing")

                        throw org.gradle.api.GradleException(
                            """
                            |================================================================================
                            |RELEASE BUILD SIGNING ERROR:
                            |Release build requires a valid release keystore configured in android/key.properties.
                            |Silently falling back to debug signing is strictly disabled for release safety.
                            |
                            |Issues detected:
                            |${missingDetails.joinToString("\n") { "| - $it" }}
                            |
                            |To configure release signing:
                            |1. Create android/key.properties containing:
                            |   storePassword=<your-store-password>
                            |   keyPassword=<your-key-password>
                            |   keyAlias=<your-key-alias>
                            |   storeFile=<path-to-your-keystore.jks>
                            |2. Ensure the keystore file exists at the specified path.
                            |================================================================================
                            """.trimMargin()
                        )
                    }
                }
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
