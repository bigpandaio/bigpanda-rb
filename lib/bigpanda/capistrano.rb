require 'bigpanda'

Capistrano::Configuration.instance(:must_exist).load do |config|

  namespace :bigpanda do

    desc '[Internal] Notifies BigPanda that a deployment has started'
    task :notify_deploy_started do
      transaction do
        on_rollback do
          notify_deploy_failed
        end

        send_deployment_start
      end
    end

    desc '[Internal] Notifies BigPanda that a deployment has finished successfuly'
    task :notify_deploy_finished do
      send_deployment_end('success')
    end

    desc '[Internal] Notifies BigPanda that a deployment has finished with an error'
    task :notify_deploy_failed do
      send_deployment_end('failure', errorMessage: 'failed to deploy')
    end

  end

  # Map capistrano execution variables to BigPanda Fields for deployment start
  #
  # == Parameters:
  #  optional Hash which can contain all propriatery fields
  #
  def send_deployment_start(properties = {})
    panda = create_bigpanda_client

    panda.deployment_start({:component => application,
                            :version => "#{fetch(:branch, '')} #{release_name}",
                            :hosts => find_servers_for_task(current_task),
                            :env => rails_env,
                            :owner => fetch(:bigpanda_owner, nil),
                            :properties => properties
                            })
  rescue Exception => e
    logger.important "err :: while sending BigPanda start, Skipping to next command. #{e.message}"
  end

  # Map capistrano execution variables to BigPanda Fields for deployment end
  #
  # == Parameters:
  #  optional Hash which can contain all propriatery fields
  #
  def send_deployment_end(status, properties = {})
    panda = create_bigpanda_client

    errorMessage = properties.delete(:errorMessage)

    panda.deployment_end({ :component => application,
                           :version => "#{fetch(:branch, '')} #{release_name}",
                           :hosts => find_servers_for_task(current_task),
                           :status => status,
                           :env => rails_env,
                           :errorMessage => errorMessage,
                           :properties => properties})
  rescue Exception => e
    logger.important "err :: while sending BigPanda start, Skipping to next command. #{e.message}"
  end


  def create_bigpanda_client
    BigPanda::Client.new(:access_token => fetch(:bigpanda_access_token, nil))
  end


  # Hooks:
  #   Wrap deploy execution

  before "deploy:update_code", "bigpanda:notify_deploy_started"
  after  "deploy", "bigpanda:notify_deploy_finished"
end
