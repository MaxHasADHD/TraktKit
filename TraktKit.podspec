Pod::Spec.new do |s|
  s.name      = "TraktKit"
  s.version   = "1.2.12"
  s.summary   = "Swift wrapper for Trakt.tv API"
  s.homepage  = "https://github.com/MaxHasADHD/TraktKit"
  s.license   = { :type => "MIT", :file => "License.md" }
  s.authors   = "Maximilian Litteral"
  s.swift_version             = "5.0"
  s.ios.deployment_target     = "12.0"
  s.osx.deployment_target     = "10.12"
  s.watchos.deployment_target = "3.0"
  s.source        = { :git => "https://github.com/MaxHasADHD/TraktKit.git", :tag => "#{s.version}" }
  s.source_files  = "Common", "Common/**/*.{h,m,swift}"
  s.requires_arc = true
end
