# Script para habilitar features via Railway SQL
puts '🚀 Habilitando todas as features premium...'

# Verificar se conseguimos conectar
begin
  puts "✅ Total de contas: #{Account.count}"
  puts "✅ Total de usuários: #{User.count}"

  # Habilitar todas as features para todas as contas
  Account.find_each do |account|
    # Definir todas as features como habilitadas
    account.feature_flags = 0xFFFFFFFF # Todos os bits habilitados
    account.save!
    puts "✅ Features habilitadas para conta: #{account.name}"
  end

  puts ''
  puts '🎉 Todas as features foram habilitadas!'
  puts 'Features ativas:'
  puts '- SLA Management'
  puts '- Audit Logs'
  puts '- Custom Roles'
  puts '- Captain Integration (IA)'
  puts '- Help Center Embedding Search'
  puts '- Disable Branding'
  puts '- Custom Reply Email/Domain'
  puts '- Linear Integration'
  puts '- Shopify Integration'
  puts '- CRM Integration'
  puts '- Direct Uploads'
  puts '- E muito mais!'

rescue StandardError => e
  puts "❌ Erro: #{e.message}"
end