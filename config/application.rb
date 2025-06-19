# frozen_string_literal: true

require_relative 'boot'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

## Load the specific APM agent
Dotenv::Rails.load
require 'ddtrace' if ENV.fetch('DD_TRACE_AGENT', false).present?
require 'elastic-apm' if ENV.fetch('ELASTIC_APM_SECRET_TOKEN', false).present?
require 'scout_apm' if ENV.fetch('SCOUT_KEY', false).present?

if ENV.fetch('NEW_RELIC_LICENSE_KEY', false).present?
  require 'newrelic-sidekiq-metrics'
  require 'newrelic_rpm'
end

if ENV.fetch('SENTRY_DSN', false).present?
  require 'sentry-ruby'
  require 'sentry-rails'
  require 'sentry-sidekiq'
end

# Railway autoscaling (ou Heroku)
if ENV.fetch('JUDOSCALE_URL', false).present?
  require 'judoscale-rails'
  require 'judoscale-sidekiq'
end

# 🔥 Declaração da constante principal
module KirvanoApp
  mattr_accessor :extensions

  self.extensions = %i[]

  # Verifica se é enterprise (se tiver a pasta enterprise ativa as features)
  def self.enterprise?
    Dir.exist?(Rails.root.join('enterprise'))
  end
end

module Kirvano
  class Application < Rails::Application
    config.load_defaults 7.0

    # Carregar libs customizadas
    config.eager_load_paths << Rails.root.join('lib')
    config.eager_load_paths << Rails.root.join('enterprise/lib')
    config.eager_load_paths << Rails.root.join('enterprise/listeners')
    config.eager_load_paths += Dir["#{Rails.root}/enterprise/app/**"]

    # Priorizar as views da pasta enterprise
    config.paths['app/views'].unshift('enterprise/app/views')

    # Geradores
    config.generators.javascripts = false
    config.generators.stylesheets = false

    # Configurações customizadas do Kirvano
    config.x = config_for(:app).with_indifferent_access

    # Correção para YAML Column serialization
    config.active_record.yaml_column_permitted_classes = [ActiveSupport::HashWithIndifferentAccess]
  end

  # 🔧 Acesso direto às configs
  def self.config
    @config ||= Rails.configuration.x
  end

  # 🔧 Configuração SSL do Redis
  def self.redis_ssl_verify_mode
    ENV['REDIS_OPENSSL_VERIFY_MODE'] == 'none' ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER
  end
end
