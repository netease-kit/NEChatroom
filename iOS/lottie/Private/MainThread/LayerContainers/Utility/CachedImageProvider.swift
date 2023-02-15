// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import CoreGraphics
import Foundation

// MARK: - CachedImageProvider

private final class CachedImageProvider: AnimationImageProvider {
  // MARK: Lifecycle

  /// Initializes an image provider with an image provider
  ///
  /// - Parameter imageProvider: The provider to load image from asset
  ///
  public init(imageProvider: AnimationImageProvider) {
    self.imageProvider = imageProvider
  }

  // MARK: Public

  public func imageForAsset(asset: ImageAsset) -> CGImage? {
    if let image = imageCache.object(forKey: asset.id as NSString) {
      return image
    }
    if let image = imageProvider.imageForAsset(asset: asset) {
      imageCache.setObject(image, forKey: asset.id as NSString)
      return image
    }
    return nil
  }

  // MARK: Internal

  let imageCache: NSCache<NSString, CGImage> = .init()
  let imageProvider: AnimationImageProvider
}

extension AnimationImageProvider {
  /// Create a cache enabled image provider which will reuse the asset image with the same asset id
  /// It wraps the current provider as image loader, and uses `NSCache` to cache the images for resue.
  /// The cache will be reset when the `animation` is reset.
  var cachedImageProvider: AnimationImageProvider {
    CachedImageProvider(imageProvider: self)
  }
}
