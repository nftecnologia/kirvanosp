# Script para criar inbox padrão via Railway
puts '🚀 Criando inbox padrão para o Kirvano...'

# Buscar a primeira conta Kirvano
account = Account.first
if account.nil?
  puts '❌ Nenhuma conta encontrada!'
  exit
end

puts "✅ Conta encontrada: #{account.name} (ID: #{account.id})"

# Verificar se já existe um web widget
web_widget = Channel::WebWidget.find_by(account: account)

if web_widget.nil?
  # Criar canal web widget
  web_widget = Channel::WebWidget.create!(
    account: account,
    website_url: 'https://www.kirvano.com',
    website_token: SecureRandom.hex(16),
    widget_color: '#1f93ff',
    welcome_title: 'Bem-vindo ao Kirvano!',
    welcome_tagline: 'Estamos aqui para ajudar. Como podemos te atender hoje?'
  )
  puts "✅ Web Widget criado: #{web_widget.website_token}"
else
  puts "✅ Web Widget já existe: #{web_widget.website_token}"
end

# Verificar se já existe inbox
inbox = Inbox.find_by(account: account, channel: web_widget)

if inbox.nil?
  # Criar inbox
  inbox = Inbox.create!(
    channel: web_widget,
    account: account,
    name: 'Suporte Kirvano',
    enable_auto_assignment: true,
    greeting_enabled: true,
    greeting_message: 'Olá! Como podemos te ajudar hoje?'
  )
  puts "✅ Inbox criado: #{inbox.name} (ID: #{inbox.id})"
else
  puts "✅ Inbox já existe: #{inbox.name} (ID: #{inbox.id})"
end

# Associar admin ao inbox
admin_user = User.find_by(email: 'admin@kirvano.com')
if admin_user
  InboxMember.find_or_create_by(user: admin_user, inbox: inbox)
  puts '✅ Admin associado ao inbox'
else
  puts '⚠️ Admin não encontrado'
end

puts ''
puts '🎉 Setup do inbox concluído!'
puts "📦 Inbox: #{inbox.name}"
puts "🌐 Web Widget Token: #{web_widget.website_token}"
puts "🔗 Website URL: #{web_widget.website_url}"