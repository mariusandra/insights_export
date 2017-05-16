$:.push File.expand_path("../lib", __FILE__)

require "insights_export/version"

Gem::Specification.new do |s|
  s.name        = 'insights_export'
  s.version     = InsightsExport::VERSION
  s.date        = '2017-05-16'
  s.summary     = "Export your database structure into config/insights.yml"
  s.description = "for use with insights."
  s.authors     = ["Marius Andra"]
  s.email       = 'marius.andra@gmail.com'
  s.files       = ["lib/insights_export.rb"] + Dir['lib/**/*rb']
  s.homepage    = 'https://github.com/mariusandra/insights_export'
  s.license     = 'MIT'
  s.require_paths = ["lib"]

  s.add_development_dependency "rake"
end
