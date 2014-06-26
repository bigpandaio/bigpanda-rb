Gem::Specification.new do |s|
  s.name         = 'bigpanda'
  s.version      = '0.1.3'
  s.date         = '2014-06-15'
  s.summary      = "A Ruby client (and additional integrations) for BigPanda's API"
  s.description  = s.summary
  s.authors      = ["BigPanda"]
  s.email        = 'support@bigpanda.io'
  s.files        = ["lib/bigpanda.rb", "lib/bigpanda/capistrano.rb", "lib/bigpanda/bp-api.rb"]
  s.homepage     = 'https://github.com/bigpandaio/bigpanda-rb'
  s.require_path = 'lib'
  s.license      = 'MIT'

  s.add_runtime_dependency 'json'
end
