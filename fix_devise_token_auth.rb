# Script para recriar usuário usando devise_token_auth corretamente
puts '🔧 Recriando usuário para DeviseTokenAuth...'

begin
  # Remover usuário existente
  existing_user = User.find_by(email: 'admin@kirvano.com')
  if existing_user
    puts 'Removendo usuário existente...'
    existing_user.destroy
  end

  # Criar usuário usando create! do Rails (que chama os callbacks corretos)
  user = User.create!(
    name: 'Kirvano Admin',
    email: 'admin@kirvano.com',
    password: 'Kirvano2025!',
    password_confirmation: 'Kirvano2025!',
    type: 'SuperAdmin',
    provider: 'email',
    uid: 'admin@kirvano.com',
    confirmed_at: Time.current
  )

  puts "✅ Usuário criado: #{user.name} (ID: #{user.id})"
  puts "Email: #{user.email}"
  puts "Provider: #{user.provider}"
  puts "UID: #{user.uid}"
  puts "Tokens inicializados: #{user.tokens.present?}"
  puts "Confirmado: #{user.confirmed_at.present?}"

  # Verificar e criar conta
  account = Account.find_or_create_by(name: 'Kirvano')
  puts "✅ Conta: #{account.name} (ID: #{account.id})"

  # Associar à conta
  account_user = AccountUser.find_or_create_by(user: user, account: account) do |au|
    au.role = :administrator
  end
  puts "✅ Associação criada: role #{account_user.role}"

  # Configurar instalação como concluída
  InstallationConfig.find_or_create_by(name: 'CHATWOOT_INSTALLATION_ONBOARDING') do |config|
    config.value = false
    config.locked = true
  end
  puts '✅ Instalação configurada'

  puts ''
  puts '🎉 Usuário DeviseTokenAuth criado com sucesso!'
  puts 'Email: admin@kirvano.com'
  puts 'Senha: Kirvano2025!'
  puts ''
  puts '🔗 Teste agora:'
  puts 'https://kirvano-web-production.up.railway.app/app/login'

rescue StandardError => e
  puts "❌ Erro: #{e.message}"
  puts e.backtrace.first(5)
end