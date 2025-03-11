/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

plugins {
    id("com.android.library")
    kotlin("android")
}

android {
    compileSdk = 31
    namespace = "com.netease.yunxin.kit.entertainment.common"
    buildFeatures {
        viewBinding = true
    }
}

dependencies {
    // jetpack dependencies
    implementation("com.google.android.material:material:1.5.0")
    implementation("androidx.recyclerview:recyclerview:1.2.1")
    implementation("com.netease.yunxin.kit:alog:1.1.0")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.6.4")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.6.4")
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.okhttp3:logging-interceptor:4.7.2")
    implementation("com.squareup.okhttp3:okhttp:4.9.3")
    api("com.netease.yunxin.kit.common:common-network:1.1.8")
    implementation("com.google.code.gson:gson:2.9.0")
    implementation("com.airbnb.android:lottie:5.0.3")
    implementation("com.netease.yunxin:nertc-base:5.4.8")


    implementation("com.netease.yunxin.kit.common:common-ui:1.3.9")
    implementation("com.netease.yunxin.kit.common:common-image:1.1.7")
    implementation(project(":voiceroomkit"))
    implementation("com.netease.yunxin.kit.core:corekit:1.4.2")
}
