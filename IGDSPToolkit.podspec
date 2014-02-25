Pod::Spec.new do |s|
  s.name             = "IGDSPToolkit"
  s.version          = "0.1.0"
  s.summary          = "Simple DSP Toolkit"
  s.description      = <<-DESC
                        This is a simple DSP toolkit, mostly for personal use.
                       DESC
  s.homepage         = "http://github.com/yanke-guo/IGDSPToolkit"
  s.license          = 'MIT'
  s.author           = { "YANKE Guo/郭琰珂" => "yanke.guo@icloud.com" }
  s.source           = { :git => "https://github.com/yanke-guo/IGDSPToolkit.git", :tag => s.version.to_s }

  s.platform     = :ios, '5.0'
  s.requires_arc = true

  s.source_files = 'IGDSPToolkit/*.{h,m}'
  s.public_header_files = 'IGDSPToolkit/*.h'
  s.frameworks = 'Accelerate'
end
