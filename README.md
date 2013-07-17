# BigPanda

A Ruby client and integrations for the BigPanda API

## Installation

Add this line to your application's Gemfile:

    gem 'bigpanda-rb'

And then execute:

    $ bundle

Or install it yourself:

    $ gem install bigpanda-rb

## Usage

### Simple Usage:

```ruby
require 'big_panda'

panda = BigPanda::Client.new(access_token: 'YOUR_TOKEN')
 # => #<BigPanda::Client:0x007fec52014d20 @config={"access_token"=>"YOUR_TOKEN", "target_url"=>"https://api.bigpanda.io", "deployment_start_path"=>"/data/events/deployments/start", "deployment_end_path"=>"/data/events/deployments/end", :access_token=>"my-access-token"}>

panda.deployment_start({ hosts: ['prod-1', 'prod-2'], component: 'billing', version: '123' })
# => {"status"=>"created"}

panda.finish_deployment({ hosts: ['prod-1', 'prod-2'], component: 'billing', version: '123' })
# => {"status"=>"created"}
```

### SSL Options
You can pass ssl options to BigPanda::Client.new
```ruby
BigPanda::Client.new(access_token: 'YOUR_TOKEN', ssl: {ca_file: '/my/cert.pem'})
```
Avalible SSL options:
```
:client_cert
:client_key
:ca_file
:ca_path
:verify_depth
:version
```

# API Documentation 
Additional documentation can be found at http://dev.bigpanda.io/docs/api
