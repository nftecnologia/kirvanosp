# Multi-stage build para otimização
FROM ruby:3.4.4 AS builder

# Instalar Node.js 20 e dependências de build
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    postgresql-client \
    libvips \
    && npm install -g yarn \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Instalar bundler
RUN gem install bundler

# Copiar e instalar gems (caching layer)
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle install && \
    bundle clean --force

# Copiar package.json e instalar dependências Node (caching layer)
COPY package.json yarn.lock* ./
RUN yarn install

# Copiar código fonte
COPY . .

# Set production environment for asset compilation
ENV RAILS_ENV=production
ENV NODE_ENV=production
ENV SECRET_KEY_BASE=dummy

# Precompilar assets com otimizações
RUN bundle exec rake assets:precompile

# Clean up build dependencies and cache
RUN yarn install --production --frozen-lockfile && \
    rm -rf node_modules/.cache && \
    rm -rf /tmp/* && \
    rm -rf ~/.cache/yarn

# Production stage
FROM ruby:3.4.4-slim AS production

# Instalar apenas dependências de runtime
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libpq5 \
    libvips \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Criar usuário não-root para segurança
RUN groupadd -r kirvano && useradd -r -g kirvano kirvano

# Copiar gems instalados do builder
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Copiar aplicação compilada
COPY --from=builder --chown=kirvano:kirvano /app /app

# Copiar script de entrypoint
COPY bin/docker-entrypoint /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint

# Configurar variáveis de ambiente de produção
ENV RAILS_ENV=production
ENV NODE_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true

# Usar usuário não-root
USER kirvano

EXPOSE 3000

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
