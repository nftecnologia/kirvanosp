-- Script para configurar planos Enterprise completos

-- Configurar features do plano Cloud
UPDATE installation_configs 
SET serialized_value = '"--- !ruby/hash:ActiveSupport::HashWithIndifferentAccess\nvalue:\n  enterprise:\n    - audit_logs\n    - custom_roles\n    - sla\n    - captain_integration\n    - disable_branding\n    - help_center_embedding_search\n    - custom_reply_email\n    - custom_reply_domain\n    - linear_integration\n    - shopify_integration\n    - crm_integration\n"'::jsonb 
WHERE name = 'CHATWOOT_CLOUD_PLAN_FEATURES';

-- Configurar planos Cloud disponíveis
UPDATE installation_configs 
SET serialized_value = '"--- !ruby/hash:ActiveSupport::HashWithIndifferentAccess\nvalue:\n  enterprise:\n    name: \"Enterprise\"\n    price: 0\n    features:\n      - \"Unlimited agents\"\n      - \"SLA Management\"\n      - \"Audit Logs\"\n      - \"Custom Roles\"\n      - \"Captain AI Integration\"\n      - \"Disable Branding\"\n      - \"Custom Reply Domain\"\n      - \"All Premium Features\"\n"'::jsonb 
WHERE name = 'CHATWOOT_CLOUD_PLANS';

-- Verificar configurações
SELECT 'Configurações Enterprise atualizadas:' as status;
SELECT name, 
  CASE 
    WHEN serialized_value::text LIKE '%enterprise%' THEN '✅ ENTERPRISE' 
    WHEN serialized_value::text LIKE '%999%' THEN '✅ UNLIMITED'
    WHEN serialized_value::text LIKE '%cloud%' THEN '✅ CLOUD'
    ELSE '⚙️ CONFIGURED' 
  END as status
FROM installation_configs 
WHERE name IN (
  'INSTALLATION_PRICING_PLAN',
  'INSTALLATION_PRICING_PLAN_QUANTITY', 
  'DEPLOYMENT_ENV',
  'CHATWOOT_CLOUD_PLAN_FEATURES',
  'CHATWOOT_CLOUD_PLANS'
);