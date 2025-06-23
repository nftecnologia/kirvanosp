-- Script mais simples para desabilitar LINE e SMS
-- Remove referências a channel_line e channel_sms das configurações

UPDATE installation_configs 
SET serialized_value = replace(
  replace(serialized_value::text, 'channel_line', 'disabled_channel_line'),
  'channel_sms', 'disabled_channel_sms'
)::jsonb
WHERE name = 'ACCOUNT_LEVEL_FEATURE_DEFAULTS' 
  AND (serialized_value::text LIKE '%channel_line%' OR serialized_value::text LIKE '%channel_sms%');

-- Verificar resultado
SELECT 'Canais LINE e SMS desabilitados' as status;
SELECT name, 
  CASE 
    WHEN serialized_value::text LIKE '%channel_line%' THEN '❌ LINE ainda presente' 
    WHEN serialized_value::text LIKE '%channel_sms%' THEN '❌ SMS ainda presente'
    ELSE '✅ LINE e SMS removidos' 
  END as status
FROM installation_configs 
WHERE name = 'ACCOUNT_LEVEL_FEATURE_DEFAULTS';