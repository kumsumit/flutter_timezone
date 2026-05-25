plugins {
    id("com.android.library")
}

group = "net.wolverinebeach.flutter_timezone"
version = "1.0-SNAPSHOT"

repositories {
    google()
    mavenCentral()
}

extensions.configure<com.android.build.api.dsl.LibraryExtension>("android") {

    namespace = "net.wolverinebeach.flutter_timezone"

    compileSdk = 37

    defaultConfig {
        minSdk = 24
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    sourceSets {
        named("main") {
            kotlin.directories.add(
                project.layout.projectDirectory.dir("src/main/kotlin")
            )
        }

        named("test") {
            kotlin.directories.add(
                project.layout.projectDirectory.dir("src/test/kotlin")
            )
        }
    }

    testOptions {
        unitTests.all {

            it.useJUnitPlatform()

            it.outputs.upToDateWhen { false }

            it.testLogging {
                events(
                    "passed",
                    "skipped",
                    "failed",
                    "standardOut",
                    "standardError"
                )

                showStandardStreams = true
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(
            org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_21
        )
    }
}

dependencies {
    testImplementation(kotlin("test"))
    testImplementation("org.mockito:mockito-core:5.23.0")
}