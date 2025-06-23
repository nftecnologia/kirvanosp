-- Verificar configurações de LINE e SMS
SELECT 'Configurações LINE e SMS:' as status;
SELECT name, 
  CASE 
    WHEN serialized_value::text LIKE '%true%' THEN '✅ HABILITADO' 
    WHEN serialized_value::text LIKE '%false%' THEN '❌ DESABILITADO'
    ELSE '⚙️ INDEFINIDO' 
  END as status,
  LEFT(serialized_value::text, 80) as value
FROM installation_configs 
WHERE name LIKE '%LINE%' 
   OR name LIKE '%SMS%' 
   OR name LIKE '%TWILIO%'
   OR name LIKE '%ACCOUNT_LEVEL_FEATURE%'
ORDER BY name;