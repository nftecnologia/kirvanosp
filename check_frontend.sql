-- Verificar configurações de frontend
SELECT 'Configurações de frontend:' as status;
SELECT name, 
  CASE 
    WHEN LENGTH(serialized_value::text) > 100 
    THEN LEFT(serialized_value::text, 100) || '...' 
    ELSE serialized_value::text 
  END as value
FROM installation_configs 
WHERE name IN (
  'FRONTEND_URL', 
  'INSTALLATION_ENV',
  'CHATWOOT_CLOUD_PLANS',
  'DIRECT_UPLOADS_ENABLED'
) 
ORDER BY name;