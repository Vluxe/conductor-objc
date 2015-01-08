Pod::Spec.new do |s|
  s.name         = "conductor-objc"
  s.version      = "0.9.0"
  s.summary      = "Objective-C client library for conductor"
  s.homepage     = "https://github.com/Vluxe/conductor-objc"
  s.license      = 'Apache License, Version 2.0'
  s.author       = { "Dalton Cherry" => "daltoniam@gmail.com" }
  s.source       = { :git => "https://github.com/Vluxe/conductor-objc.git", :tag => "#{s.version}" }
  s.social_media_url = 'http://twitter.com/daltoniam'
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
  s.source_files = '*.{h,m}'
  s.dependency 'jetfire'
  s.requires_arc = true
end
