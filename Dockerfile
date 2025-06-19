FROM ruby:3.4.4

# Instala dependências
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  yarn \
  libvips

# Diretório da aplicação
WORKDIR /app

# Copia Gemfile e instala as gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler
RUN bundle install

# Copia o restante da aplicação
COPY . .

# Instala dependências JS
RUN yarn install

# Precompila assets
RUN bundle exec rake assets:precompile

EXPOSE 3000

# Comando padrão
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
