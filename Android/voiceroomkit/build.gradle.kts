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
    // androidx
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.6.4")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.6.4")
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.okhttp3:okhttp:4.9.3")
    implementation("androidx.core:core-ktx:1.7.0")

    // xkit
    implementation("com.netease.yunxin.kit:alog:1.1.0")
    implementation("com.netease.yunxin.kit.common:common:1.3.1")
    implementation("com.netease.yunxin.kit.common:common-network:1.1.8")
    implementation("com.netease.yunxin.kit.room:roomkit:1.20.0")

    implementation("com.google.code.gson:gson:2.9.0")
}
