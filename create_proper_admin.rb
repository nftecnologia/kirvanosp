# Script para recriar usuário admin corretamente via Rails
puts '🔧 Recriando usuário Super Admin via Rails...'

# Remover usuário existente se houver
existing_user = User.find_by(email: 'admin@kirvano.com')
if existing_user
  puts 'Removendo usuário existente...'
  existing_user.destroy
end

# Criar usuário usando os métodos corretos do Rails
begin
  user = User.new(
    name: 'Kirvano Admin',
    email: 'admin@kirvano.com',
    password: 'Kirvano2025!',
    password_confirmation: 'Kirvano2025!',
    type: 'SuperAdmin'
  )

  # Configurar campos obrigatórios do Devise
  user.provider = 'email'
  user.uid = 'admin@kirvano.com'

  # Pular confirmação de email
  user.skip_confirmation!

  # Salvar usuário
  if user.save!
    puts "✅ Usuário criado com ID: #{user.id}"

    # Criar conta se não existir
    account = Account.find_or_create_by(name: 'Kirvano')
    puts "✅ Conta encontrada/criada: #{account.name} (ID: #{account.id})"

    # Associar usuário à conta como administrador
    account_user = AccountUser.find_or_create_by(
      user: user,
      account: account
    ) do |au|
      au.role = :administrator
    end

    puts "✅ Usuário associado à conta com role: #{account_user.role}"
    puts ''
    puts '🎉 Setup completo!'
    puts "Email: #{user.email}"
    puts 'Senha: Kirvano2025!'
    puts "Tipo: #{user.type}"
    puts ''
    puts '🔗 Login: https://kirvano-web-production.up.railway.app/app/login'

  else
    puts '❌ Erro ao criar usuário:'
    puts user.errors.full_messages.join("\n")
  end

rescue StandardError => e
  puts '❌ Erro durante criação:'
  puts e.message
  puts e.backtrace.first(5)
end