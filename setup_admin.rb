# Script para criar usuário super admin no Kirvano
puts '🚀 Criando usuário Super Admin no Kirvano...'

email = 'admin@kirvano.com'
password = 'Kirvano2025!'
name = 'Kirvano Admin'

# Verificar se usuário já existe
existing_user = User.find_by(email: email)

if existing_user
  puts "⚠️  Usuário com email #{email} já existe!"
  puts "User ID: #{existing_user.id}"
  puts "User Type: #{existing_user.type}"
else
  # Criar super admin user
  user = User.new(
    name: name,
    email: email,
    password: password,
    password_confirmation: password,
    type: 'SuperAdmin'
  )

  # Pular confirmação de email
  user.skip_confirmation!

  if user.save!
    puts '✅ Super Admin criado com sucesso!'
    puts "Email: #{user.email}"
    puts "Nome: #{user.name}"
    puts "Tipo: #{user.type}"
    puts "ID: #{user.id}"
    puts ''
    puts '🔑 Credenciais de login:'
    puts "Email: #{email}"
    puts "Password: #{password}"

    # Criar conta padrão
    account = Account.create!(name: 'Kirvano')

    # Associar admin com a conta
    AccountUser.create!(
      account_id: account.id,
      user_id: user.id,
      role: :administrator
    )

    puts ''
    puts "✅ Conta padrão criada: #{account.name}"
    puts '🎉 Setup completo!'
  else
    puts '❌ Erro ao criar super admin:'
    puts user.errors.full_messages.join("\n")
  end
end