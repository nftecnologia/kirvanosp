-- Criar usuário super admin no Kirvano
INSERT INTO users (
  name, 
  email, 
  encrypted_password, 
  type, 
  created_at, 
  updated_at,
  confirmed_at
) VALUES (
  'Kirvano Admin',
  'admin@kirvano.com',
  '$2a$12$k8rOw.8bZfhKCjbXbj7GhOYrn8g9GqE.Yg.x0k7/J3Fg1s2N6uPWC',
  'SuperAdmin',
  NOW(),
  NOW(),
  NOW()
) ON CONFLICT (email) DO NOTHING;

-- Verificar se foi criado
SELECT id, name, email, type FROM users WHERE email = 'admin@kirvano.com';

-- Criar conta padrão se não existir
INSERT INTO accounts (name, created_at, updated_at) 
VALUES ('Kirvano', NOW(), NOW()) 
ON CONFLICT DO NOTHING;

-- Associar usuário à conta
INSERT INTO account_users (user_id, account_id, role, created_at, updated_at)
SELECT u.id, a.id, 0, NOW(), NOW()
FROM users u, accounts a 
WHERE u.email = 'admin@kirvano.com' 
AND a.name = 'Kirvano'
ON CONFLICT DO NOTHING; 