-- Criar usuário normal no Kirvano
-- Senha: senha123 (hash BCrypt)

-- Primeiro, garantir que existe uma conta
INSERT INTO accounts (name, created_at, updated_at) 
VALUES ('Kirvano', NOW(), NOW()) 
ON CONFLICT DO NOTHING;

-- Criar usuário normal
INSERT INTO users (
  name, 
  email, 
  encrypted_password, 
  type, 
  created_at, 
  updated_at,
  confirmed_at,
  uid,
  provider
) VALUES (
  'Usuario Teste',
  'usuario@kirvano.com',
  '$2a$12$k8rOw.8bZfhKCjbXbj7GhOYrn8g9GqE.Yg.x0k7/J3Fg1s2N6uPWC',
  'User',
  NOW(),
  NOW(),
  NOW(),
  'usuario@kirvano.com',
  'email'
) ON CONFLICT (email) DO UPDATE SET
  encrypted_password = EXCLUDED.encrypted_password,
  confirmed_at = NOW(),
  updated_at = NOW();

-- Associar usuário à conta como admin
INSERT INTO account_users (user_id, account_id, role, created_at, updated_at)
SELECT u.id, a.id, 1, NOW(), NOW()  -- role 1 = administrator
FROM users u, accounts a 
WHERE u.email = 'usuario@kirvano.com' 
AND a.name = 'Kirvano'
ON CONFLICT (user_id, account_id) DO UPDATE SET
  role = EXCLUDED.role,
  updated_at = NOW();

-- Verificar se foi criado
SELECT u.id, u.name, u.email, u.type, au.role, a.name as account_name
FROM users u 
LEFT JOIN account_users au ON u.id = au.user_id
LEFT JOIN accounts a ON au.account_id = a.id
WHERE u.email = 'usuario@kirvano.com'; 