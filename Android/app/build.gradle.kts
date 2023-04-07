/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

plugins {
    id("com.android.application")
    kotlin("android")
}

android {
    compileSdk = 31
    defaultConfig {
        minSdk = 21
        targetSdk = 30
        applicationId = "com.netease.yunxin.app.chatroom"
        versionCode = 350
        versionName = "3.5.0"
        multiDexEnabled = true
    }

    buildFeatures {
        viewBinding = true
    }

    lint {
        baseline = file("lint-baseline.xml")
        abortOnError = false
    }

    packagingOptions {
        jniLibs.pickFirsts.add("lib/arm64-v8a/libc++_shared.so")
        jniLibs.pickFirsts.add("lib/armeabi-v7a/libc++_shared.so")
    }
}


dependencies {
    implementation("androidx.appcompat:appcompat:1.4.2")
    implementation("com.google.android.material:material:1.5.0")
    implementation(project(":ordersong"))
    implementation(project(":voiceroomkit-ui"))
    implementation(project(":entertainment:entertainment-common"))
    implementation("com.netease.yunxin.kit.common:common-image:1.1.6")
    implementation("com.netease.yunxin.kit.common:common-ui:1.1.13")
     implementation("com.netease.yunxin.kit.auth:auth-yunxin-login:1.0.4-rc01")
    implementation("com.netease.yunxin.kit:alog:1.0.9")
    implementation("com.blankj:utilcodex:1.30.6")
    implementation("com.gyf.immersionbar:immersionbar:3.0.0")
    implementation("com.scwang.smart:refresh-layout-kernel:2.0.1")
    implementation("com.netease.yunxin.kit.voiceroom:voiceroomkit:1.1.0")
    implementation("com.netease.yunxin.kit.copyrightedmedia:copyrightedmedia:1.6.0")

}
