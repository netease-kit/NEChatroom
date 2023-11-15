# ---------- NECoreKit ----------
module NECoreKit
  def self.use_path
    true
  end

  def self.name
    "NECoreKit"
  end

  def self.version
    "9.6.3"
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
    "9.6.3-alpha01"
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
