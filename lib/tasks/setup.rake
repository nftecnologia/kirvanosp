namespace :setup do
  desc 'Create super admin user for Kirvano'
  task create_super_admin: :environment do
    email = ENV.fetch('ADMIN_EMAIL', 'admin@kirvano.com')
    password = ENV.fetch('ADMIN_PASSWORD', 'Kirvano2025!')
    name = ENV.fetch('ADMIN_NAME', 'Kirvano Admin')

    # Check if super admin already exists
    existing_user = User.find_by(email: email)
    
    if existing_user
      puts "⚠️  User with email #{email} already exists!"
      puts "User ID: #{existing_user.id}"
      puts "User Type: #{existing_user.type}"
      return
    end

    # Create super admin user
    user = User.new(
      name: name,
      email: email,
      password: password,
      password_confirmation: password,
      type: 'SuperAdmin'
    )
    
    # Skip email confirmation for super admin
    user.skip_confirmation!
    
    if user.save!
      puts "✅ Super Admin user created successfully!"
      puts "Email: #{user.email}"
      puts "Name: #{user.name}"
      puts "Type: #{user.type}"
      puts "ID: #{user.id}"
      puts ""
      puts "🔑 Login credentials:"
      puts "Email: #{email}"
      puts "Password: #{password}"
    else
      puts "❌ Failed to create super admin user:"
      puts user.errors.full_messages.join("\n")
    end
  end

  desc 'Create default account and setup'
  task create_default_account: :environment do
    account_name = ENV.fetch('ACCOUNT_NAME', 'Kirvano')
    admin_email = ENV.fetch('ADMIN_EMAIL', 'admin@kirvano.com')

    # Find super admin user
    admin_user = User.find_by(email: admin_email, type: 'SuperAdmin')
    
    unless admin_user
      puts "❌ Super admin user not found! Run 'rake setup:create_super_admin' first."
      return
    end

    # Check if account already exists
    existing_account = Account.find_by(name: account_name)
    
    if existing_account
      puts "⚠️  Account '#{account_name}' already exists!"
      puts "Account ID: #{existing_account.id}"
      return
    end

    # Create default account
    account = Account.create!(name: account_name)
    
    # Associate admin with account
    AccountUser.create!(
      account_id: account.id,
      user_id: admin_user.id,
      role: :administrator
    )

    puts "✅ Default account created successfully!"
    puts "Account Name: #{account.name}"
    puts "Account ID: #{account.id}"
    puts "Admin User: #{admin_user.email}"
  end

  desc 'Complete Kirvano setup (create super admin + default account)'
  task complete: :environment do
    puts "🚀 Starting Kirvano complete setup..."
    puts ""
    
    Rake::Task['setup:create_super_admin'].invoke
    puts ""
    Rake::Task['setup:create_default_account'].invoke
    puts ""
    
    puts "🎉 Kirvano setup completed!"
    puts ""
    puts "You can now login at: #{Rails.application.routes.url_helpers.new_user_session_url}"
  end
end 