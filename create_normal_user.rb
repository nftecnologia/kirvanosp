#!/usr/bin/env ruby

# Script para criar usuário normal no Kirvano
puts '🚀 Criando usuário normal no Kirvano...'

# Garantir que existe uma conta
account = Account.find_or_create_by(name: 'Kirvano') do |a|
  a.created_at = Time.current
  a.updated_at = Time.current
end

puts "✅ Conta '#{account.name}' garantida (ID: #{account.id})"

# Criar usuário normal
user = User.find_or_initialize_by(email: 'usuario@kirvano.com')

if user.persisted?
  puts '📋 Usuário já existe, atualizando...'
else
  puts '👤 Criando novo usuário...'
end

user.assign_attributes(
  name: 'Usuario Teste',
  encrypted_password: '$2a$12$k8rOw.8bZfhKCjbXbj7GhOYrn8g9GqE.Yg.x0k7/J3Fg1s2N6uPWC', # senha123
  type: 'User',
  confirmed_at: Time.current,
  uid: 'usuario@kirvano.com',
  provider: 'email'
)

user.save!

puts "✅ Usuário '#{user.name}' criado/atualizado (ID: #{user.id})"

# Associar usuário à conta como administrador
account_user = AccountUser.find_or_initialize_by(
  user_id: user.id,
  account_id: account.id
)

account_user.assign_attributes(
  role: 1  # 1 = administrator
)

account_user.save!

puts '✅ Usuário associado à conta como administrador'
puts ''
puts '🎉 Usuário criado com sucesso!'
puts '📧 Email: usuario@kirvano.com'
puts '🔐 Senha: senha123'
puts ''
puts 'Você pode agora fazer login com essas credenciais.'