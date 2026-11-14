// Top-level build file where you can add configuration options common to all sub-projects/modules.
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    id("com.android.application") version "8.2.2" apply false
    id("com.android.library") version "8.2.2" apply false
    kotlin("android") version "1.9.22" apply false
}

// Keep Java and Kotlin bytecode targets aligned for every Android module.
// The CI runner uses JDK 17 and Kotlin 1.9.22; mismatched targets fail
// Kotlin's compile-time compatibility validation.
subprojects {
    tasks.withType<org.gradle.api.tasks.compile.JavaCompile>().configureEach {
        sourceCompatibility = JavaVersion.VERSION_17.toString()
        targetCompatibility = JavaVersion.VERSION_17.toString()
    }

    tasks.withType<KotlinCompile>().configureEach {
        kotlinOptions {
            jvmTarget = "17"
        }
    }
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}
