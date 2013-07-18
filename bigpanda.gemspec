Gem::Specification.new do |s|
  s.name        = 'bigpanda'
  s.version     = '0.1.0'
  s.date        = '2013-07-17'
  s.summary     = "Ruby client and integrations for the BigPanda API"
  s.description = s.summary
  s.authors     = ["BigPanda"]
  s.email       = 'support@bigpanda.io'
  s.files       = ["lib/bigpanda.rb", "lib/bigpanda/capistrano.rb", "lib/bigpanda/bp-api.rb"]
  s.homepage    = 'https://github.com/bigpandaio/bigpanda-rb'
  s.require_path = 'lib'

  s.add_runtime_dependency 'json'
end
