# ---------- NERoomKit ----------
module NERoomKit
  def self.use_path
    true
  end

  def self.name
    "NERoomKit"
  end

  def self.version
    "1.20.0"
  end

  def self.path
    "RoomKit/NERoomKit/NERoomKit.podspec"
  end

  def self.Special_All
    "NERoomKit/Special_All"
  end

  def self.Base_Special
    "NERoomKit/Base_Special"
  end

  def self.Beauty_Special
    "NERoomKit/Beauty_Special"
  end

  def self.Segment_Special
    "NERoomKit/Segment_Special"
  end

  def self.Audio_Special
    "NERoomKit/Audio_Special"
  end

  def self.ShareScreen_Special
    "NERoomKit/ShareScreen_Special"
  end

  def self.Base
    "NERoomKit/Base"
  end

  def Base_FCS
    "NERoomKit/Base_FCS"
  end

  def self.Beauty
    "NERoomKit/Beauty"
  end

  def self.Segment
    "NERoomKit/Segment"
  end

  def self.Audio
    "NERoomKit/Audio"
  end

  def self.ShareScreen
    "NERoomKit/ShareScreen"
  end

  def self.install(pod)
    if NERoomKit.use_path
      puts "NERoomKit use path"
      pod.pod NERoomKit.name, :path => NERoomKit.path
    else
      puts "NERoomKit use http"
      pod.pod NERoomKit.name, NERoomKit.version
    end
  end
end
