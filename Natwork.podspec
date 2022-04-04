Pod::Spec.new do |s|
  s.name             = 'Natwork'
  s.version          = '0.1.0'
  s.summary          = 'Testable Network in Swift'
  s.description      = <<-DESC
Natwork is an HTTP networking library written in Swift, which describes the returning error and makes each layer testable.
                       DESC

  s.homepage         = 'https://github.com/mockada/Natwork'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jade Silveira' => 'jadecs8@gmail.com' }
  s.source           = { :git => 'https://github.com/mockada/Natwork.git', :tag => s.version.to_s }
   s.social_media_url = 'https://twitter.com/mockada'

  s.ios.deployment_target = '9.0'

  s.source_files = 'Natwork/Classes/**/*'
  s.swift_versions = "4.0"
end
