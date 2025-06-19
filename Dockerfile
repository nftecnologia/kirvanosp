# Stage 1: Build dependencies
FROM node:23-bullseye AS node_builder

# Habilita pnpm
RUN corepack enable

WORKDIR /app

# Copia arquivos de dependências
COPY package.json pnpm-lock.yaml ./

# Instala dependências JS
RUN pnpm install --frozen-lockfile --prod=false

# Stage 2: Ruby app
FROM ruby:3.4.4

# Instala Node.js 23 e dependências do sistema
RUN curl -fsSL https://deb.nodesource.com/setup_23.x | bash - && \
    apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    postgresql-client \
    nodejs \
    libvips \
    && rm -rf /var/lib/apt/lists/*

# Habilita pnpm
RUN corepack enable

WORKDIR /app

# Copia node_modules do stage anterior
COPY --from=node_builder /app/node_modules ./node_modules

# Copia Gemfile e instala gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install

# Copia arquivos da aplicação
COPY . .

# Copia script de inicialização
COPY bin/docker-entrypoint /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint

# Precompila assets
RUN RAILS_ENV=production bundle exec rake assets:precompile

EXPOSE 3000

# Define entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]

# Comando padrão
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
