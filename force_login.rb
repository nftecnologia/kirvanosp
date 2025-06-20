# Script para forçar login e configurar sessão administrativa
puts '🔧 Configurando sessão administrativa...'

begin
  # Encontrar o usuário
  user = User.find_by(email: 'admin@kirvano.com')

  if user.nil?
    puts '❌ Usuário não encontrado!'
    exit 1
  end

  puts "✅ Usuário encontrado: #{user.name} (ID: #{user.id})"

  # Verificar se é Super Admin
  if user.type != 'SuperAdmin'
    user.update!(type: 'SuperAdmin')
    puts '✅ Tipo atualizado para SuperAdmin'
  end

  # Verificar se está confirmado
  if user.confirmed_at.nil?
    user.update!(confirmed_at: Time.current)
    puts '✅ Usuário confirmado'
  end

  # Verificar conta
  account = Account.find_by(name: 'Kirvano')
  if account.nil?
    account = Account.create!(name: 'Kirvano')
    puts '✅ Conta criada'
  else
    puts "✅ Conta encontrada: #{account.name}"
  end

  # Verificar associação
  account_user = AccountUser.find_or_create_by(user: user, account: account) do |au|
    au.role = :administrator
  end
  puts "✅ Associação criada: role #{account_user.role}"

  # Configurar instalação como concluída
  InstallationConfig.find_or_create_by(name: 'CHATWOOT_INSTALLATION_ONBOARDING') do |config|
    config.value = false
    config.locked = true
  end
  puts '✅ Instalação marcada como concluída'

  # Limpar cache global
  if defined?(GlobalConfig)
    GlobalConfig.clear_cache
    puts '✅ Cache global limpo'
  end

  puts ''
  puts '🎉 Configuração administrativa completa!'
  puts "Email: #{user.email}"
  puts 'Senha: Kirvano2025!'
  puts "ID: #{user.id}"
  puts "Tipo: #{user.type}"
  puts "Confirmado: #{user.confirmed_at.present?}"
  puts ''
  puts '🔗 Tente agora:'
  puts 'https://kirvano-web-production.up.railway.app/app/login'
  puts 'https://kirvano-web-production.up.railway.app/super_admin'

rescue StandardError => e
  puts "❌ Erro: #{e.message}"
  puts e.backtrace.first(3)
end