-- Verificar configurações dos canais sociais
SELECT 'Configurações de canais sociais:' as status;
SELECT name, 
  CASE 
    WHEN serialized_value::text LIKE '%true%' THEN '✅ HABILITADO' 
    WHEN serialized_value::text LIKE '%false%' THEN '❌ DESABILITADO'
    ELSE '⚙️ INDEFINIDO' 
  END as status,
  LEFT(serialized_value::text, 100) as value
FROM installation_configs 
WHERE name IN (
  'ENABLE_MESSENGER_CHANNEL_HUMAN_AGENT',
  'ENABLE_INSTAGRAM_CHANNEL_HUMAN_AGENT',
  'FB_APP_ID',
  'FB_VERIFY_TOKEN',
  'FB_APP_SECRET',
  'IG_VERIFY_TOKEN'
)
ORDER BY name;