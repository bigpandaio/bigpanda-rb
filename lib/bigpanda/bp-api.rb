require 'yaml'
require 'json'
require 'net/https'

module BigPanda

  VERSION               = '0.1.0'

  DEFAULT_CONFIG_FILES  = [ "/etc/bigpanda.yaml", "/etc/bigpanda.yml" ]
  DEFAULT_CONFIGURATION = { # overridable via the configuration file
    :access_token          => nil,
    :target_url            => 'https://api.bigpanda.io',
    :deployment_start_path => '/data/events/deployments/start',
    :deployment_end_path   => '/data/events/deployments/end'
  }

  #
  # Main BigPanda API Class
  #
  # The client needs to be initialized with the access_token of the organization.
  # Possible options:
  # 1. Pass the access_token as a :access_token parameter
  # 2. Place a bigpanda.yaml file in /etc/ and add to the file -  'access_token': YOUR_TOKEN
  # 3. Pass a location of a yaml file using the :file parameter
  #
  #
  class Client
    attr_reader :config, :ssl

    def initialize(options = {})

      unless options.fetch(:access_token, nil)
        file = options.delete(:file)
        file_config, config_files = read_config_from_file(file)
        options.merge!(file_config) if file_config
      end

      @config = DEFAULT_CONFIGURATION.merge(options)
      @ssl = options.delete(:ssl) || {}

      unless @config.fetch(:access_token, nil)
        raise "No BigPanda config token received, and no configuration file found. Searched: #{config_files.join ','}."
      end
    end

    def deployment_start(options = {})
      return deployment_notification config[:deployment_start_path], options
    end

    def deployment_end(options = {})
      return deployment_notification config[:deployment_end_path], options
    end

    private

      class Error < RuntimeError; end
      class Unauthorized < RuntimeError; end

      # Prepare the call to BigPanda API and send a HTTP Request
      #
      def deployment_notification(path, options)
        place_default_values(options)

        return request path, JSON.generate(options)
      end

      # Perform the actual request to BigPanda API
      #
      def request(path, body, target_url = config[:target_url])
        headers  = { 'Accept' => 'application/json',
                     'Content-Type' => 'application/json',
                     'Authorization' => "Bearer #{config[:access_token]}" }

        uri = URI.parse(target_url)
        h = Net::HTTP.new uri.host, uri.port
        h.set_debug_output $stderr if $DEBUG
        h.use_ssl = (uri.scheme.downcase == 'https')

        set_ssl_overrides(h)

        h.start do |http|
          response = http.request_post path, body, headers
          raise Unauthorized if response.code.to_i == 401
          raise Error, "server error: #{response.body}" if response.code.to_i >= 500

          answer = JSON.load(response.body)['response']
          raise Error, answer['errors'].join(", ") if response.code.to_i >= 400

          return answer
        end
      end

      def place_default_values(options)
        options[:timestamp] = options.fetch(:timestamp, Time.now.utc.to_i) # unix time

        if options.has_key?(:hosts)
          options[:hosts] = options[:hosts].kind_of?(Array) ? options[:hosts] : [options[:hosts]]
        end

        unless options.has_key?(:source_system)
          options[:source_system] = "ruby"
        end

      end

      # Read configuration from the default list of configuration files and the received file.
      #
      # Returns the the found configuration and the list of files which were used.
      #
      def read_config_from_file(file)

        config_files = ([file] + DEFAULT_CONFIG_FILES).compact
        config = nil

        config_files.each do |config_file|
          if File.exists? config_file
            config = YAML.load_file(config_file)

            # Convert string keys to symbols
            config.keys.each do |key|
              config[(key.to_sym rescue key) || key] = config.delete(key)
            end
          end
        end

        return config, config_files
      end

      def set_ssl_overrides(http)
        http.certificate  = ssl[:client_cert]  if ssl[:client_cert]
        http.private_key  = ssl[:client_key]   if ssl[:client_key]
        http.ca_file      = ssl[:ca_file]      if ssl[:ca_file]
        http.ssl_version  = ssl[:version]      if ssl[:version]
        http.verify_mode  = ssl[:verify_mode]  if ssl[:verify_mode]
      end

    end
end

