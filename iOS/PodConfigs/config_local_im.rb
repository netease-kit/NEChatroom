# ---------- NERtcCallKit ----------
module NERtcCallKit
  def self.use_path
    true
  end

  def self.name
    "NERtcCallKit"
  end

  def self.version
    "2.1.0-alpha02"
  end

  def self.path
    "CallKit/NERtcCallKit/NERtcCallKit.podspec"
  end

  def self.NOS
    "NERtcCallKit/NOS"
  end

  def self.FCS
    "NERtcCallKit/FCS"
  end

  def self.NOS_Special
    "NERtcCallKit/NOS_Special"
  end

  def self.FCS_Special
    "NERtcCallKit/FCS_Special"
  end

  def self.install(pod)
    if NERtcCallKit.use_path
      puts "NERtcCallKit use path"
      pod.pod NERtcCallKit.name, :path => NERtcCallKit.path
    else
      puts "NERtcCallKit use http"
      pod.pod NERtcCallKit.name, NERtcCallKit.version
    end
  end
end

# ---------- NECallKitPstn ----------
module NECallKitPstn
  def self.use_path
    true
  end

  def self.name
    "NECallKitPstn"
  end

  def self.version
    "2.1.0"
  end

  def self.NOS
    "NECallKitPstn/NOS"
  end

  def self.FCS
    "NECallKitPstn/FCS"
  end

  def self.NOS_Special
    "NECallKitPstn/NOS_Special"
  end

  def self.FCS_Special
    "NECallKitPstn/FCS_Special"
  end

  def self.path
    "CallKit/NECallKitPstn/NECallKitPstn.podspec"
  end

  def self.install(pod)
    if NECallKitPstn.use_path
      puts "NECallKitPstn use path"
      pod.pod NECallKitPstn.name, :path => NECallKitPstn.path
    else
      puts "NECallKitPstn use http"
      pod.pod NECallKitPstn.name, NECallKitPstn.version
    end
  end
end

# ---------- NERtcCallUIKit ----------
module NERtcCallUIKit
  def self.use_path
    true
  end

  def self.name
    "NERtcCallUIKit"
  end

  def self.version
    "2.1.0-alpha02"
  end

  def self.path
    "CallKit/NERtcCallUIKit/NERtcCallUIKit.podspec"
  end

  def self.install(pod)
    if NERtcCallUIKit.use_path
      puts "NERtcCallUIKit use path"
      pod.pod NERtcCallUIKit.name, :path => NERtcCallUIKit.path
    else
      puts "NERtcCallUIKit use http"
      pod.pod NERtcCallUIKit.name, NERtcCallUIKit.version
    end
  end
end

# ---------- NEContactUIKit ----------
module NEContactUIKit
  def self.use_path
    true
  end

  def self.name
    "NEContactUIKit"
  end

  def self.version
    "9.6.1"
  end

  def self.path
    "IMUIKit/NEContactUIKit/NEContactUIKit.podspec"
  end

  def self.install(pod)
    if NEContactUIKit.use_path
      puts "NEContactUIKit use path"
      pod.pod NEContactUIKit.name, :path => NEContactUIKit.path
    else
      puts "NEContactUIKit use http"
      pod.pod NEContactUIKit.name, NEContactUIKit.version
    end
  end
end

# ---------- NEConversationUIKit ----------
module NEConversationUIKit
  def self.use_path
    true
  end

  def self.name
    "NEConversationUIKit"
  end

  def self.version
    "9.6.3-alpha01"
  end

  def self.path
    "IMUIKit/NEConversationUIKit/NEConversationUIKit.podspec"
  end

  def self.install(pod)
    if NEConversationUIKit.use_path
      puts "NEConversationUIKit use path"
      pod.pod NEConversationUIKit.name, :path => NEConversationUIKit.path
    else
      puts "NEConversationUIKit use http"
      pod.pod NEConversationUIKit.name, NEConversationUIKit.version
    end
  end
end

# ---------- NEMapKit ----------
module NEMapKit
  def self.use_path
    true
  end

  def self.name
    "NEMapKit"
  end

  def self.version
    "9.6.0"
  end

  def self.path
    "Common/NEMapKit/NEMapKit.podspec"
  end

  def self.install(pod)
    if NEMapKit.use_path
      puts "NEMapKit use path"
      pod.pod NEMapKit.name, :path => NEMapKit.path
    else
      puts "NEMapKit use http"
      pod.pod NEMapKit.name, NEMapKit.version
    end
  end
end

# ---------- NETeamUIKit ----------
module NETeamUIKit
  def self.use_path
    true
  end

  def self.name
    "NETeamUIKit"
  end

  def self.version
    "9.6.1"
  end

  def self.path
    "IMUIKit/NETeamUIKit/NETeamUIKit.podspec"
  end

  def self.install(pod)
    if NETeamUIKit.use_path
      puts "NETeamUIKit use path"
      pod.pod NETeamUIKit.name, :path => NETeamUIKit.path
    else
      puts "NETeamUIKit use http"
      pod.pod NETeamUIKit.name, NETeamUIKit.version
    end
  end
end

# ---------- NEChatKit ----------
module NEChatKit
  def self.use_path
    true
  end

  def self.name
    "NEChatKit"
  end

  def self.version
    "9.6.3-alpha01"
  end

  def self.path
    "IMUIKit/NEChatKit/NEChatKit.podspec"
  end

  def self.NOS
    "NEChatKit/NOS"
  end

  def self.FCS
    "NEChatKit/FCS"
  end

  def self.NOS_Special
    "NEChatKit/NOS_Special"
  end

  def self.FCS_Special
    "NEChatKit/FCS_Special"
  end

  def self.install(pod)
    if NEChatKit.use_path
      puts "NEChatKit use path"
      pod.pod NEChatKit.name, :path => NEChatKit.path
    else
      puts "NEChatKit use http"
      pod.pod NEChatKit.name, NEChatKit.version
    end
  end
end

# ---------- NEChatUIKit ----------
module NEChatUIKit
  def self.use_path
    true
  end

  def self.name
    "NEChatUIKit"
  end

  def self.version
    "9.6.3-alpha01"
  end

  def self.path
    "IMUIKit/NEChatUIKit/NEChatUIKit.podspec"
  end

  def self.NOS
    "NEChatUIKit/NOS"
  end

  def self.FCS
    "NEChatUIKit/FCS"
  end

  def self.NOS_Special
    "NEChatUIKit/NOS_Special"
  end

  def self.FCS_Special
    "NEChatUIKit/FCS_Special"
  end

  def self.install(pod)
    if NEChatUIKit.use_path
      puts "NEChatUIKit use path"
      pod.pod NEChatUIKit.name, :path => NEChatUIKit.path
    else
      puts "NEChatUIKit use http"
      pod.pod NEChatUIKit.name, NEChatUIKit.version
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

  def self.version
    "9.6.0"
  end

  def self.path
    "CoreKit/NECoreQChatKit/NECoreQChatKit.podspec"
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

# ---------- NEQChatKit ----------
module NEQChatKit
  def self.use_path
    true
  end

  def self.name
    "NEQChatKit"
  end

  def self.version
    "9.6.0"
  end

  def self.path
    "IMUIKit/NEQChatKit/NEQChatKit.podspec"
  end

  def self.NOS
    "NEQChatKit/NOS"
  end

  def self.FCS
    "NEQChatKit/FCS"
  end

  def self.NOS_Special
    "NEQChatKit/NOS_Special"
  end

  def self.FCS_Special
    "NEQChatKit/FCS_Special"
  end

  def self.install(pod)
    if NEQChatKit.use_path
      puts "NEQChatKit use path"
      pod.pod NEQChatKit.name, :path => NEQChatKit.path
    else
      puts "NEQChatKit use http"
      pod.pod NEQChatKit.name, NEQChatKit.version
    end
  end
end

# ---------- NEQChatUIKit ----------
module NEQChatUIKit
  def self.use_path
    true
  end

  def self.name
    "NEQChatUIKit"
  end

  def self.version
    "9.6.1"
  end

  def self.path
    "IMUIKit/NEQChatUIKit/NEQChatUIKit.podspec"
  end

  def self.install(pod)
    if NEQChatUIKit.use_path
      puts "NEQChatUIKit use path"
      pod.pod NEQChatUIKit.name, :path => NEQChatUIKit.path
    else
      puts "NEQChatUIKit use http"
      pod.pod NEQChatUIKit.name, NEQChatUIKit.version
    end
  end
end
