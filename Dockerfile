# Usar Ruby oficial e instalar Node.js 20 diretamente
FROM ruby:3.4.4

# Instalar Node.js 20 e dependências
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    postgresql-client \
    libvips \
    && corepack enable \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Instalar bundler
RUN gem install bundler

# Copiar e instalar gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copiar package.json e instalar dependências Node
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Copiar aplicação
COPY . .

# Copiar script
COPY bin/docker-entrypoint /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint

# Precompilar assets
RUN RAILS_ENV=production SECRET_KEY_BASE=dummy bundle exec rake assets:precompile

EXPOSE 3000

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
