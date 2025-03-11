# ---------- NECoreKit ----------
module NECoreKit
  def self.use_path
    true
  end

  def self.name
    "NECoreKit"
  end

  def self.version
    "9.7.2"
  end

  def self.path
    "CoreKit/NECoreKit/NECoreKit.podspec"
  end

  def self.install(pod)
    if NECoreKit.use_path
      puts "NECoreKit use path"
      pod.pod NECoreKit.name, :path => NECoreKit.path
    else
      puts "NECoreKit use http"
      pod.pod NECoreKit.name, NECoreKit.version
    end
  end
end

# ---------- NECoreIMKit ----------
module NECoreIMKit
  def self.use_path
    true
  end

  def self.name
    "NECoreIMKit"
  end

  def self.version
    "10.0.0"
  end

  def self.path
    "CoreKit/NECoreIMKit/NECoreIMKit.podspec"
  end

  def self.NOS
    "NECoreIMKit/NOS"
  end

  def self.NOS_Special
    "NECoreIMKit/NOS_Special"
  end

  def self.FCS
    "NECoreIMKit/FCS"
  end

  def self.FCS_Special
    "NECoreIMKit/FCS_Special"
  end

  def self.install(pod)
    if NECoreIMKit.use_path
      puts "NECoreIMKit use path"
      pod.pod NECoreIMKit.name, :path => NECoreIMKit.path
    else
      puts "NECoreIMKit use http"
      pod.pod NECoreIMKit.name, NECoreIMKit.version
    end
  end
end

# ---------- NECoreIM2Kit ----------
module NECoreIM2Kit
  def self.use_path
    true
  end

  def self.name
    "NECoreIM2Kit"
  end

  def self.version
    "1.0.6"
  end

  def self.path
    "CoreKit/NECoreIM2Kit/NECoreIM2Kit.podspec"
  end

  def self.NOS
    "NECoreIM2Kit/NOS"
  end

  def self.NOS_Special
    "NECoreIM2Kit/NOS_Special"
  end

  def self.FCS
    "NECoreIM2Kit/FCS"
  end

  def self.FCS_Special
    "NECoreIM2Kit/FCS_Special"
  end

  def self.install(pod)
    if NECoreIM2Kit.use_path
      puts "NECoreIM2Kit use path"
      pod.pod NECoreIM2Kit.name, :path => NECoreIM2Kit.path
    else
      puts "NECoreIM2Kit use http"
      pod.pod NECoreIM2Kit.name, NECoreIM2Kit.version
    end
  end
end

# ---------- NECoreQChatKit ----------
module NECoreQChatKit
  def self.use_path
    true
  end

  def self.name
    "NECoreQChatKit"
  end

  def self.path
    "CoreKit/NECoreQChatKit/NECoreQChatKit.podspec"
  end

  def self.NOS
    "NECoreQChatKit/NOS"
  end

  def self.NOS_Special
    "NECoreQChatKit/NOS_Special"
  end

  def self.FCS
    "NECoreQChatKit/FCS"
  end

  def self.FCS_Special
    "NECoreQChatKit/FCS_Special"
  end

  def self.install(pod)
    if NECoreQChatKit.use_path
      puts "NECoreQChatKit use path"
      pod.pod NECoreQChatKit.name, :path => NECoreQChatKit.path
    else
      puts "NECoreQChatKit use http"
      pod.pod NECoreQChatKit.name, NECoreQChatKit.version
    end
  end
end
