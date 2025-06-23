-- Verificar canais disponíveis após mudança
SELECT 'Status dos canais após desabilitação:' as info;

-- Verificar se LINE e SMS aparecem nas configurações
SELECT 
  CASE 
    WHEN serialized_value::text LIKE '%channel_line%' THEN '❌ LINE ainda disponível'
    ELSE '✅ LINE removido'
  END as line_status,
  CASE 
    WHEN serialized_value::text LIKE '%channel_sms%' THEN '❌ SMS ainda disponível'  
    ELSE '✅ SMS removido'
  END as sms_status,
  CASE 
    WHEN serialized_value::text LIKE '%channel_email%' THEN '✅ Email disponível'
    ELSE '❌ Email removido'
  END as email_status,
  CASE 
    WHEN serialized_value::text LIKE '%channel_website%' THEN '✅ Website disponível'
    ELSE '❌ Website removido'  
  END as website_status
FROM installation_configs 
WHERE name = 'ACCOUNT_LEVEL_FEATURE_DEFAULTS';