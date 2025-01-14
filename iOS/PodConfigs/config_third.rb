# ---------- SDWebImage ----------
module SDWebImage
  def self.name
    "SDWebImage"
  end

  def self.version
    "5.15.4"
  end

  def self.install(pod)
    pod.pod SDWebImage.name, SDWebImage.version
  end
end

# ---------- NIMSDK ----------
module NIMSDK
  def self.name
    "NIMSDK_LITE"
  end

  def self.version
    "9.17.0"
  end

  def self.version10
    "10.6.0"
  end

  def self.FCS
    "NIMSDK_LITE/FCS"
  end
end

# ---------- NERtcSDK ----------
module NERtcSDK
  def self.name
    "NERtcSDK"
  end

  def self.version
    "5.6.42"
  end

  def self.RtcBasic
    "#{NERtcSDK.name}/RtcBasic"
  end

  def self.Nenn
    "#{NERtcSDK.name}/Nenn"
  end

  def self.Beauty
    "#{NERtcSDK.name}/Beauty"
  end

  def self.FaceDetect
    "#{NERtcSDK.name}/FaceDetect"
  end

  def self.Segment
    "#{NERtcSDK.name}/Segment"
  end

  def self.AiDenoise
    "#{NERtcSDK.name}/AiDenoise"
  end

  def self.AiHowling
    "#{NERtcSDK.name}/AiHowling"
  end

  def self.ScreenShare
    "#{NERtcSDK.name}/ScreenShare"
  end
  def self.FaceEnhance
    "#{NERtcSDK.name}/FaceEnhance"
  end
  def self.VideoDenoise
    "#{NERtcSDK.name}/VideoDenoise"
  end
  def self.SuperResolution
    "#{NERtcSDK.name}/SuperResolution"
  end
  def self.SpatialSound
    "#{NERtcSDK.name}/SpatialSound"
  end
end

# ---------- Masonry ----------
module Masonry
  def self.name
    "Masonry"
  end

  def self.version
    "1.1.0"
  end

  def self.install(pod)
    pod.pod Masonry.name, Masonry.version
  end
end

# ---------- AMap ----------
module AMap
  def self.name
    "AMap"
  end

  def self.version
    "5.6.1"
  end

  def self.install(pod)
    pod.pod AMap.name, AMap.version
  end
end

# ---------- BlocksKit ----------
module BlocksKit
  def self.name
    "BlocksKit"
  end

  def self.path
    "third_party/BlocksKit/BlocksKit.podspec"
  end

  def self.install(pod)
    pod.pod BlocksKit.name, :path => BlocksKit.path
  end
end

# ---------- IHProgressHUD ----------
module IHProgressHUD
  def self.name
    "IHProgressHUD"
  end

  def self.path
    "third_party/IHProgressHUD/IHProgressHUD.podspec"
  end

  def self.install(pod)
    pod.pod IHProgressHUD.name, :path => IHProgressHUD.path
  end
end

# ---------- LottieOC ----------
module LottieOC
  def self.name
    "lottie-ios"
  end

  def self.version
    "2.5.3"
  end

  def self.install(pod)
    pod.pod LottieOC.name, LottieOC.version
  end
end

# ---------- Lottie ----------
module Lottie
  def self.name
    "lottie-ios"
  end

  def self.version
    "4.4.0"
  end

  def self.install(pod)
    pod.pod Lottie.name, Lottie.version
  end
end

# ---------- LottieSwift ----------
module LottieSwift
  def self.name
    "LottieSwift"
  end

  def self.path
    "third_party/lottie/LottieSwift.podspec"
  end

  def self.install(pod)
    pod.pod LottieSwift.name, :path => LottieSwift.path
  end
end

# ---------- MJRefresh ----------
module MJRefresh
  def self.name
    "MJRefresh"
  end

  def self.version
    "3.7.5"
  end

  def self.install(pod)
    pod.pod MJRefresh.name, MJRefresh.version
  end
end

# ---------- SnapKit ----------
module SnapKit
  def self.name
    "SnapKit"
  end

  def self.version
    "5.6.0"
  end

  def self.install(pod)
    pod.pod SnapKit.name, SnapKit.version
  end
end

# ---------- Marvel ----------
module Marvel
  def self.name
    "Marvel"
  end

  def self.version
    "1.0.6.7"
  end

  def self.install(pod)
    pod.pod Marvel.name, Marvel.version
  end
end

# ---------- YYText ----------
module YYText
  def self.name
    "YYText"
  end

  def self.path
    "third_party/YYText/YYText.podspec"
  end

  def self.install(pod)
    pod.pod YYText.name, :path => YYText.path
  end
end

# ---------- GCDWebServer ----------
module GCDWebServer
  def self.name
    "GCDWebServer"
  end

  def self.version
    "3.5.4"
  end

  def self.install(pod)
    pod.pod GCDWebServer.name, GCDWebServer.version
  end
end

# ---------- FaceUnity ----------
module FaceUnity
  def self.name
    "FaceUnity"
  end

  def self.path
    "third_party/FaceUnity/FaceUnity.podspec"
  end

  def self.install(pod)
    pod.pod FaceUnity.name, :path => FaceUnity.path
  end
end

# ---------- SVProgressHUD ----------
module SVProgressHUD
  def self.name
    "SVProgressHUD"
  end

  def self.version
    "2.2.5"
  end

  def self.install(pod)
    pod.pod SVProgressHUD.name, SVProgressHUD.version
  end
end

# ---------- YXAlog ----------
module YXAlog
  def self.name
    "YXAlog"
  end

  def self.version
    "1.0.7"
  end

  def self.install(pod)
    pod.pod YXAlog.name, YXAlog.version
  end
end

# ---------- SudMGPWrapper ----------
module SudMGPWrapper
  def self.name
    "SudMGPWrapper"
  end

  def self.version
    "1.3.5"
  end

  def self.install(pod)
    pod.pod SudMGPWrapper.name, SudMGPWrapper.version
  end
end

# ---------- libyuv ----------
module Libyuv
  def self.name
    "libyuv-iOS"
  end

  def self.version
    "1.0.2"
  end

  def self.install(pod)
    pod.pod Libyuv.name, Libyuv.version
  end
end
