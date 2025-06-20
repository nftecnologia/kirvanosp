-- Recriar usuário compatível com devise_token_auth
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
  custom_attributes,
  tokens,
  pubsub_token
) VALUES (
  'email',
  'admin@kirvano.com',
  '$2a$12$vrydWoPZdIqvKdIcYIEWSO8a3l66xCTNiEVPZuALYuIx2XhVSBKrK',
  'Kirvano Admin',
  'admin@kirvano.com',
  'SuperAdmin',
  NOW(),
  NOW(),
  NOW(),
  0,
  0,
  '{}',
  '{}',
  '{}',
  'admin_token_' || extract(epoch from now())::text
) RETURNING id, name, email, type, provider, uid, tokens;

-- Associar à conta
INSERT INTO account_users (user_id, account_id, role, created_at, updated_at)
SELECT u.id, a.id, 0, NOW(), NOW()
FROM users u, accounts a 
WHERE u.email = 'admin@kirvano.com' 
AND a.name = 'Kirvano'
RETURNING id, user_id, account_id, role; 