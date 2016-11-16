
Pod::Spec.new do |s|
  s.name                  = "Template"
  s.version               = "1.0.0"
  s.summary               = "Template"
  s.homepage              = "xx"
  s.license               = { :type => 'Copyright', :text => "xx copyright" }
  s.author                = { "xx" => "xx.xx@xx" }

  s.requires_arc          = true
  s.ios.deployment_target = '7.0'

  s.platform = :ios
  s.source_files  = "Sources/**/*.{h,m}"
  s.resources  = 'Resources/*.bundle'
  #s.public_header_files = "Sources/public/**/*.h"
  s.prefix_header_file = 'SupportingFiles/Template-Prefix.pch'

  s.xcconfig = {
  'FRAMEWORK_SEARCH_PATHS' =>" '$(PODS_ROOT)/Template' ",
  'OTHER_LDFLAGS' => '-ObjC -lstdc++ -lc++'
  }


end



