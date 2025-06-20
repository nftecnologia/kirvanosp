-- Criar usuário super admin no Kirvano (SQL corrigido)
INSERT INTO users (
  provider,
  uid,
  encrypted_password,
  name,
  email,
  type,
  confirmed_at,
  created_at,
  updated_at,
  sign_in_count,
  availability,
  ui_settings,
  custom_attributes
) VALUES (
  'email',
  'admin@kirvano.com',
  '$2a$12$k8rOw.8bZfhKCjbXbj7GhOYrn8g9GqE.Yg.x0k7/J3Fg1s2N6uPWC',
  'Kirvano Admin',
  'admin@kirvano.com',
  'SuperAdmin',
  NOW(),
  NOW(),
  NOW(),
  0,
  0,
  '{}',
  '{}'
);

-- Verificar se foi criado
SELECT id, name, email, type, provider, uid FROM users WHERE email = 'admin@kirvano.com'; 