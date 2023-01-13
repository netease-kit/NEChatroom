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
    implementation ("androidx.swiperefreshlayout:swiperefreshlayout:1.1.0")
    // third party dependencies
    implementation("com.airbnb.android:lottie:5.0.3")
    implementation("com.gyf.immersionbar:immersionbar:3.0.0")
    implementation("com.blankj:utilcodex:1.30.6")

    // xkit dependencies
    implementation("com.netease.yunxin.kit.room:roomkit:1.11.0")
    implementation("com.netease.yunxin.kit.common:common-network:1.1.7")
    implementation("com.netease.yunxin.kit.common:common-image:1.1.6")
    implementation("com.netease.yunxin.kit.common:common-ui:1.1.13")
    implementation(project(":listentogetherkit"))
    implementation(project(":ordersong"))
    implementation("com.netease.yunxin.kit.copyrightedmedia:copyrightedmedia:1.5.0")
    implementation("com.netease.yunxin.kit.karaoke:karaokekit-lyric-ui:1.4.0")
    implementation("com.netease.yunxin.kit:alog:1.0.9")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.6.4")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.6.4")
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.okhttp3:okhttp:4.9.3")

}
