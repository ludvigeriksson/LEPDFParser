Pod::Spec.new do |s|

  s.name         = "LEPDFParser"
  s.version      = "0.1"
  s.summary      = "Parse PDF metadata in Swift."

  s.description  = <<-DESC
    LEPDFParser adds a single calculated property to PDFKit's PDFPage called 'dictionary'. It will contain the metadata of the page, including gepgraphical data for geo-tagged PDF documents.
                   DESC

  s.license      = "MIT"

  s.author       = { "Ludvig Eriksson" => "ludvigeriksson@icloud.com" }
  s.homepage     = "https://github.com/ludvigeriksson/LEPDFParser"

  s.platform     = :ios
  s.ios.deployment_target = "11.0"
  s.swift_version = "4.0"

  s.source       = { :git => "https://github.com/ludvigeriksson/LEPDFParser.git", :tag => "#{s.version}" }

  s.source_files  = "LEPDFParser/Classes", "LEPDFParser/Classes/*.{h,m,swift}"
  s.exclude_files = "Classes/Exclude"

  s.framework  = "PDFKit"

end
