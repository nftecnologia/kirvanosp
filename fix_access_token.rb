# Script para criar access_token para o usuário admin
puts '🔧 Corrigindo access_token para admin...'

# Encontrar o usuário admin
user = User.find_by(email: 'admin@kirvano.com')

if user.nil?
  puts '❌ Usuário admin não encontrado!'
  exit
end

puts "✅ Usuário encontrado: #{user.name} (#{user.email})"

# Verificar se já tem access_token
if user.access_token
  puts "✅ Access token já existe: #{user.access_token.token}"
else
  puts '🔄 Criando access_token...'

  # Criar access_token
  access_token = user.create_access_token!

  if access_token.persisted?
    puts "✅ Access token criado com sucesso: #{access_token.token}"
  else
    puts '❌ Erro ao criar access_token:'
    puts access_token.errors.full_messages.join("\n")
  end
end

puts '🎉 Correção finalizada!'