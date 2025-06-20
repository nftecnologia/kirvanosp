# 🚂 Deploy no Railway - Kirvano

## Problemas Resolvidos

❌ **Erros Originais:**
```bash
# Erro 1: Package manager incorreto
✕ [8/9] RUN yarn install 
process "/bin/sh -c yarn install" did not complete successfully: exit code: 1

# Erro 2: Node.js 23 + Multi-stage build
✕ [node_builder 5/5] RUN pnpm install --frozen-lockfile --prod=false 
process "/bin/sh -c pnpm install --frozen-lockfile --prod=false" did not complete successfully: exit code: 1

# Erro 3: Instalação Node.js 23 com timeout
✕ [stage-1  2/11] RUN curl -fsSL https://deb.nodesource.com/setup_23.x | bash -
context canceled: exit code: 137
```

✅ **Soluções Aplicadas:**
- ✅ Corrigido de `yarn` para `pnpm`
- ✅ Downgrade de Node.js 23.x para 20.x LTS (mais estável)
- ✅ Single-stage build (evita problemas de memória)
- ✅ Instalação direta do Node.js via NodeSource
- ✅ Package.json ajustado para `>=20.0.0`

## Dockerfile Atual (Simplificado)

```dockerfile
FROM ruby:3.4.4

# Instalar Node.js 20 e dependências
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    apt-get install -y --no-install-recommends \
    build-essential libpq-dev postgresql-client libvips \
    && corepack enable && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Instalar gems e dependências Node.js
COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Copiar aplicação e precompilar
COPY . .
RUN RAILS_ENV=production SECRET_KEY_BASE=dummy bundle exec rake assets:precompile
```

## Configuração do Railway

### 1. Variáveis de Ambiente Necessárias

```bash
# Database
DATABASE_URL=postgresql://user:password@host:port/database

# Rails
RAILS_ENV=production
RAILS_MASTER_KEY=<sua_master_key>
SECRET_KEY_BASE=<sua_secret_key>

# Redis (para Sidekiq)
REDIS_URL=redis://user:password@host:port

# Outros
NODE_ENV=production
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
```

### 2. Serviços Configurados

#### Web Service
- **Start Command:** `bundle exec puma -C config/puma.rb`
- **Port:** 3000
- **Build Command:** Automático via Dockerfile

#### Worker Service  
- **Start Command:** `bundle exec sidekiq -C config/sidekiq.yml`
- **Build Command:** Automático via Dockerfile

### 3. Deploy Steps

1. **Connect Repository:**
   ```bash
   railway link https://github.com/nftecnologia/kirvanosp
   ```

2. **Configure Database:**
   - Adicione PostgreSQL plugin no Railway
   - Configure as variáveis de ambiente

3. **Configure Redis:**
   - Adicione Redis plugin no Railway
   - Configure REDIS_URL

4. **Deploy:**
   ```bash
   railway up
   ```

## Dockerfile Alternativo (Se ainda houver problemas)

Se o Dockerfile principal ainda tiver problemas, use o `Dockerfile.minimal`:

```bash
# No Railway, configure para usar:
# Build Command: docker build -f Dockerfile.minimal .
```

O `Dockerfile.minimal` usa a imagem `cimg/ruby:3.4.4-node` que já tem Ruby + Node.js pré-instalados.

## Troubleshooting

### Build ainda falha com Node.js 20
1. Use o `Dockerfile.minimal` em vez do principal
2. Configure no Railway: `Build Command: docker build -f Dockerfile.minimal .`

### Problemas com pnpm
1. Verifique se `pnpm-lock.yaml` está no repositório
2. Tente regenerar: `rm pnpm-lock.yaml && pnpm install`
3. Commit e push das mudanças

### Timeout na instalação
1. Railway tem limite de tempo de build
2. Use Dockerfile.minimal (mais rápido)
3. Considere remover devDependencies do build de produção

### Assets não carregam
1. Confirme `RAILS_SERVE_STATIC_FILES=true`
2. Verifique se assets foram precompilados
3. Confirme RAILS_MASTER_KEY

### Worker não inicia
1. Confirme que Redis está configurado
2. Verifique REDIS_URL
3. Logs do worker: `railway logs --service=worker`

## Comandos Úteis

```bash
# Logs em tempo real
railway logs --follow

# Shell no container
railway shell

# Deploy específico
railway up --service=web
railway up --service=worker

# Status dos serviços
railway status

# Rebuild completo
railway up --detach
```

## Stack Técnico Final

- **Ruby:** 3.4.4
- **Node.js:** 20.x LTS (estável)
- **Package Manager:** pnpm >= 9.0.0
- **Database:** PostgreSQL
- **Background Jobs:** Sidekiq + Redis
- **Web Server:** Puma
- **Assets:** Vite + Rails Asset Pipeline
- **Deploy:** Railway

## Mudanças Aplicadas

### package.json
```json
{
  "engines": {
    "node": ">=20.0.0",
    "pnpm": ">=9.0.0"
  }
}
```

### Dockerfile
- Single-stage build (mais simples)
- Node.js 20.x LTS
- Instalação otimizada de dependências
- Precompilação de assets com SECRET_KEY_BASE dummy

O deploy no Railway agora deve funcionar perfeitamente! 🚂✨ 