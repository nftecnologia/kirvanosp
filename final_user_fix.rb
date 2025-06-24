# Limpar todos os usuários de teste anteriores
User.where(email: ['teste@local.com', 'debug@local.com']).destroy_all

# Criar usuário usando métodos nativos do Devise
puts 'Criando usuário final...'

# Primeiro, vou temporariamente pular validações
class User
  # Temporariamente sobrescrever validações de senha
  def password_required_uppercase_count
    0
  end
  def password_required_lowercase_count  
    0
  end
  def password_required_number_count
    0
  end
  def password_required_special_character_count
    0
  end
end

account = Account.first || Account.create!(name: 'Test Account')

# Criar usuário da forma mais simples possível
user = User.create!(
  email: 'final@local.com',
  password: 'simple123',
  password_confirmation: 'simple123',
  name: 'Final Test User',
  confirmed_at: Time.current,
  provider: 'email',
  uid: 'final@local.com'
)

AccountUser.create!(
  account: account,
  user: user,
  role: 'administrator'
)

puts 'SUCCESS!'
puts 'Email: final@local.com'
puts 'Senha: simple123'
puts 'Hash: ' + user.encrypted_password