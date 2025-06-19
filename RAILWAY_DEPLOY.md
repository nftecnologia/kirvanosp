# 🚂 Deploy no Railway - Kirvano

## Problema Resolvido

❌ **Erro Original:**
```
✕ [8/9] RUN yarn install 
process "/bin/sh -c yarn install" did not complete successfully: exit code: 1
```

✅ **Solução Aplicada:**
- Corrigido package manager de `yarn` para `pnpm`
- Atualizado Node.js para versão 23.x (conforme especificado no projeto)
- Adicionado multi-stage build para otimizar o processo

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

## Arquivos de Configuração

### `Dockerfile`
- Multi-stage build com Node.js 23 e Ruby 3.4.4
- Instalação correta do pnpm
- Precompilação de assets
- Script de inicialização com health checks

### `railway.yml`
- Configuração dos serviços web e worker
- Variáveis de ambiente padrão
- Comandos de start específicos

### `bin/docker-entrypoint`
- Script de inicialização com health checks
- Aguarda disponibilidade do banco
- Executa migrações automaticamente

## Troubleshooting

### Build Fails
1. Verifique se todas as variáveis estão configuradas
2. Confirme que o PostgreSQL está disponível
3. Verifique logs do build: `railway logs --service=web`

### Worker não inicia
1. Confirme que Redis está configurado
2. Verifique REDIS_URL
3. Logs do worker: `railway logs --service=worker`

### Assets não carregam
1. Confirme `RAILS_SERVE_STATIC_FILES=true`
2. Verifique se assets foram precompilados
3. Confirme RAILS_MASTER_KEY

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
```

## Stack Technique

- **Ruby:** 3.4.4
- **Node.js:** 23.x
- **Package Manager:** pnpm 10.x
- **Database:** PostgreSQL
- **Background Jobs:** Sidekiq + Redis
- **Web Server:** Puma
- **Assets:** Vite + Rails Asset Pipeline 