#!/usr/bin/env ruby

# Connect to database
require 'pg'

# Database connection
conn = PG.connect(ENV.fetch('DATABASE_URL', nil))

begin
  # Update user type from SuperAdmin to User
  result = conn.exec("UPDATE users SET type = 'User' WHERE email = 'admin@kirvano.com' AND type = 'SuperAdmin'")

  puts '✅ Usuário admin@kirvano.com atualizado com sucesso!'
  puts "📝 Rows affected: #{result.cmd_tuples}"

  # Verify the change
  user_check = conn.exec("SELECT id, email, type, name FROM users WHERE email = 'admin@kirvano.com'")
  if user_check.ntuples > 0
    user = user_check[0]
    puts '📋 Usuário atual:'
    puts "   ID: #{user['id']}"
    puts "   Email: #{user['email']}"
    puts "   Name: #{user['name']}"
    puts "   Type: #{user['type']}"
  end

rescue PG::Error => e
  puts "❌ Erro ao conectar com o banco: #{e.message}"
ensure
  conn.close if conn
end