// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit

@objcMembers public class NESocialGiftModel: NSObject {
  public var giftId: Int
  public var icon: UIImage?
  public var displayName: String
  public var price: Int
  public var animation: String

  init(giftId: Int, icon: UIImage?, displayName: String, price: Int, animation: String) {
    self.giftId = giftId
    self.icon = icon
    self.displayName = displayName
    self.price = price
    self.animation = animation
  }

  public static func defaultGifts() -> [NESocialGiftModel] {
    [
      NESocialGiftModel(giftId: 1, icon: NESocialBundle.loadImage("gift01_ico"), displayName: NESocialBundle.localized("Glow_Stick"), price: 9, animation: "anim_gift_01"),
      NESocialGiftModel(giftId: 2, icon: NESocialBundle.loadImage("gift02_ico"), displayName: NESocialBundle.localized("Arrange"), price: 99, animation: "anim_gift_02"),
      NESocialGiftModel(giftId: 3, icon: NESocialBundle.loadImage("gift03_ico"), displayName: NESocialBundle.localized("Sports_Car"), price: 199, animation: "anim_gift_03"),
      NESocialGiftModel(giftId: 4, icon: NESocialBundle.loadImage("gift04_ico"), displayName: NESocialBundle.localized("Rockets"), price: 999, animation: "anim_gift_04"),
    ]
  }

  public static func getGift(giftId: Int) -> NESocialGiftModel? {
    defaultGifts().first(where: { $0.giftId == giftId })
  }
}
