// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import CoreGraphics
import Foundation

/// Image provider is a protocol that is used to supply images to `LottieAnimationView`.
///
/// Some animations require a reference to an image. The image provider loads and
/// provides those images to the `LottieAnimationView`.  Lottie includes a couple of
/// prebuilt Image Providers that supply images from a Bundle, or from a FilePath.
///
/// Additionally custom Image Providers can be made to load images from a URL,
/// or to Cache images.
public protocol AnimationImageProvider {
  func imageForAsset(asset: ImageAsset) -> CGImage?
}
