source 'https://rubygems.org'

ruby '3.4.4'

##-- base gems for rails --##
gem 'rack-cors', '2.0.0', require: 'rack/cors'
gem 'rails', '~> 7.1'
gem 'bootsnap', require: false

##-- rails application helper gems --##
gem 'acts-as-taggable-on'
gem 'attr_extras'
gem 'browser'
gem 'hashie'
gem 'jbuilder'
gem 'kaminari'
gem 'responders', '>= 3.1.1'
gem 'rest-client'
gem 'telephone_number'
gem 'time_diff'
gem 'tzinfo-data'
gem 'valid_email2'
gem 'uglifier'
gem 'flag_shih_tzu'
gem 'haikunator'
gem 'liquid'
gem 'commonmarker'
gem 'json_schemer'
gem 'json_refs'
gem 'rack-attack', '>= 6.7.0'
gem 'down'
gem 'gmail_xoauth'
gem 'net-smtp',  '~> 0.3.4'
gem 'csv-safe'

##-- para active storage com Cloudflare R2 --##
gem 'aws-sdk-s3', require: false
gem 'google-cloud-storage', '>= 1.48.0', require: false # opcional
gem 'image_processing'

##-- banco de dados --##
gem 'groupdate'
gem 'pg'
gem 'redis'
gem 'redis-namespace'
gem 'activerecord-import'

##--- servidor & infra ---##
gem 'dotenv-rails', '>= 3.0.0'
gem 'foreman'
gem 'puma'
gem 'vite_rails'
gem 'barnes'

##--- autenticação & autorização ---##
gem 'devise', '>= 4.9.4'
gem 'devise-secure_password', git: 'https://github.com/chatwoot/devise-secure_password', branch: 'master'
gem 'devise_token_auth', '>= 1.2.3'
gem 'jwt'
gem 'pundit'
gem 'administrate', '>= 0.20.1'
gem 'administrate-field-active_storage', '>= 1.0.3'
gem 'administrate-field-belongs_to_search', '>= 0.9.0'

##--- pubsub ---##
gem 'wisper', '2.0.0'

##--- canais de atendimento ---##
gem 'facebook-messenger'
gem 'line-bot-api'
gem 'twilio-ruby', '~> 5.66'
gem 'twitty', '~> 0.1.5'
gem 'koala'
gem 'slack-ruby-client', '~> 2.5.2'
gem 'google-cloud-dialogflow-v2', '>= 0.24.0'
gem 'grpc'
gem 'google-cloud-translate-v3', '>= 0.7.0'

##-- APM e logs --##
gem 'ddtrace', require: false
gem 'elastic-apm', require: false
gem 'newrelic_rpm', require: false
gem 'newrelic-sidekiq-metrics', '>= 1.6.2', require: false
gem 'scout_apm', require: false
gem 'sentry-rails', '>= 5.19.0', require: false
gem 'sentry-ruby', require: false
gem 'sentry-sidekiq', '>= 5.19.0', require: false

##-- background jobs --##
gem 'sidekiq', '>= 7.3.1'
gem 'sidekiq-cron', '>= 1.12.0'

##-- push notifications --##
gem 'fcm'
gem 'web-push', '>= 3.0.1'

##-- geolocalização --##
gem 'geocoder'
gem 'maxminddb'

gem 'hairtrigger'
gem 'procore-sift'
gem 'email_reply_trimmer'
gem 'html2text'
gem 'working_hours'
gem 'pg_search'
gem 'stripe'

##-- utilitários --##
gem 'faker'
gem 'lograge', '~> 0.14.0', require: false
gem 'omniauth-oauth2'
gem 'audited', '~> 5.4', '>= 5.4.1'
gem 'omniauth', '>= 2.1.2'
gem 'omniauth-google-oauth2', '>= 1.1.3'
gem 'omniauth-rails_csrf_protection', '~> 1.0', '>= 1.0.2'

##-- IA e NLP --##
gem 'neighbor'
gem 'pgvector'
gem 'reverse_markdown'
gem 'iso-639'
gem 'ruby-openai'
gem 'shopify_api'

##-- ambientes específicos --##
group :production do
  gem 'rack-timeout'
  gem 'judoscale-rails', require: false
  gem 'judoscale-sidekiq', require: false
end

group :development do
  gem 'annotate'
  gem 'bullet'
  gem 'letter_opener'
  gem 'scss_lint', require: false
  gem 'web-console', '>= 4.2.1'
  gem 'squasher'
  gem 'rack-mini-profiler', '>= 3.2.0', require: false
  gem 'stackprof'
  gem 'meta_request', '>= 0.8.3'
end

group :test do
  gem 'database_cleaner'
  gem 'webmock'
  gem 'test-prof'
end

group :development, :test do
  gem 'active_record_query_trace'
  gem 'brakeman'
  gem 'bundle-audit', require: false
  gem 'byebug', platform: :mri
  gem 'climate_control'
  gem 'debug', '~> 1.8'
  gem 'factory_bot_rails', '>= 6.4.3'
  gem 'listen'
  gem 'mock_redis'
  gem 'pry-rails'
  gem 'rspec_junit_formatter'
  gem 'rspec-rails', '>= 6.1.5'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'seed_dump'
  gem 'shoulda-matchers'
  gem 'simplecov', '0.17.1', require: false
  gem 'spring'
  gem 'spring-watcher-listen'
end
