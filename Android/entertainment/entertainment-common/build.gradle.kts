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
    buildFeatures {
        viewBinding = true
    }
}

dependencies {
    // jetpack dependencies
    implementation("com.google.android.material:material:1.5.0")
    implementation("androidx.recyclerview:recyclerview:1.2.1")
    implementation("com.netease.yunxin.kit:alog:1.0.9")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.6.4")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.6.4")
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.okhttp3:logging-interceptor:4.7.2")
    implementation("com.squareup.okhttp3:okhttp:4.9.3")


    implementation("com.airbnb.android:lottie:5.0.3")
    implementation("com.netease.yunxin:nertc-base:4.6.43")
    implementation("com.gyf.immersionbar:immersionbar:3.0.0")
    implementation("com.blankj:utilcodex:1.30.6")
    api("com.scwang.smart:refresh-layout-kernel:2.0.3")
    api("androidx.swiperefreshlayout:swiperefreshlayout:1.1.0")


    implementation("com.netease.yunxin.kit.common:common-ui:1.1.16")
    implementation("com.netease.yunxin.kit.common:common-image:1.1.7")
    implementation("com.netease.yunxin.kit.voiceroom:voiceroomkit:1.1.0")
    implementation("com.netease.yunxin.kit.auth:auth-yunxin-login:1.0.4")

}
