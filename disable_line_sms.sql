-- Script para desabilitar LINE e SMS dos canais disponíveis
-- Atualiza as features defaults para remover LINE e SMS

UPDATE installation_configs 
SET serialized_value = '--- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
value:
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: inbound_emails
  display_name: Inbound Emails
  enabled: true
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: channel_email
  display_name: Email Channel
  enabled: true
  help_url: https://chwt.app/hc/email
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: channel_facebook
  display_name: Facebook Channel
  enabled: true
  help_url: https://chwt.app/hc/fb
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: channel_twitter
  display_name: Twitter Channel
  enabled: true
  deprecated: true
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: ip_lookup
  display_name: IP Lookup
  enabled: true
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: disable_branding
  display_name: Disable Branding
  enabled: true
  premium: true
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: email_continuity_on_api_channel
  display_name: Email Continuity on API Channel
  enabled: true
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: help_center
  display_name: Help Center
  enabled: true
  help_url: https://chwt.app/hc/help-center
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: agent_bots
  display_name: Agent Bots
  enabled: true
  help_url: https://chwt.app/hc/agent-bots
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: macros
  display_name: Macros
  enabled: true
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: agent_management
  display_name: Agent Management
  enabled: true
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: team_management
  display_name: Team Management
  enabled: true
  help_url: https://chwt.app/hc/teams
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: inbox_management
  display_name: Inbox Management
  enabled: true
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: labels
  display_name: Labels
  enabled: true
  help_url: https://chwt.app/hc/labels
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: custom_attributes
  display_name: Custom Attributes
  enabled: true
  help_url: https://chwt.app/hc/custom-attributes
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: automations
  display_name: Automations
  enabled: true
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: canned_responses
  display_name: Canned Responses
  enabled: true
  help_url: https://chwt.app/hc/canned
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: integrations
  display_name: Integrations
  enabled: true
  help_url: https://chwt.app/hc/integrations
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: voice_recorder
  display_name: Voice Recorder
  enabled: true
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: mobile_v2
  display_name: Mobile App V2
  enabled: true
  deprecated: false
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: channel_website
  display_name: Website Channel
  enabled: true
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: campaigns
  display_name: Campaigns
  enabled: true
  help_url: https://chwt.app/hc/campaigns
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: reports
  display_name: Reports
  enabled: true
  help_url: https://chwt.app/hc/reports
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: crm
  display_name: CRM
  enabled: true
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: auto_resolve_conversations
  display_name: Auto Resolve Conversations
  enabled: true
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: custom_reply_email
  display_name: Custom Reply Email
  enabled: true
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: custom_reply_domain
  display_name: Custom Reply Domain
  enabled: true
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: audit_logs
  display_name: Audit Logs
  enabled: true
  premium: true
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: response_bot
  display_name: Response Bot
  enabled: true
  premium: true
  deprecated: false
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: message_reply_to
  display_name: Message Reply To
  enabled: true
  help_url: https://chwt.app/hc/reply-to
  deprecated: false
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: insert_article_in_reply
  display_name: Insert Article in Reply
  enabled: true
  deprecated: false
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: inbox_view
  display_name: Inbox View
  enabled: true
  kirvano_internal: true
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: sla
  display_name: SLA
  enabled: true
  premium: true
  help_url: https://chwt.app/hc/sla
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: help_center_embedding_search
  display_name: Help Center Embedding Search
  enabled: true
  premium: true
  kirvano_internal: true
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: linear_integration
  display_name: Linear Integration
  enabled: true
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: captain_integration
  display_name: Captain
  enabled: true
  premium: true
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: custom_roles
  display_name: Custom Roles
  enabled: true
  premium: true
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: kirvano_v4
  display_name: Kirvano V4
  enabled: true
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: report_v4
  display_name: Report V4
  enabled: true
  deprecated: false
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: contact_kirvano_support_team
  display_name: Contact Kirvano Support Team
  enabled: true
  kirvano_internal: true
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: shopify_integration
  display_name: Shopify Integration
  enabled: true
  kirvano_internal: true
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: search_with_gin
  display_name: Search messages with GIN
  enabled: true
  kirvano_internal: true
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: channel_instagram
  display_name: Instagram Channel
  enabled: true
- !ruby/hash:ActiveSupport::HashWithIndifferentAccess
  name: crm_integration
  display_name: CRM Integration
  enabled: true
'::jsonb 
WHERE name = 'ACCOUNT_LEVEL_FEATURE_DEFAULTS';

-- Verificar resultado
SELECT 'LINE e SMS removidos dos canais disponíveis' as status;
SELECT 'Canais habilitados:' as info;
SELECT regexp_split_to_table(serialized_value::text, 'channel_') as channels 
FROM installation_configs 
WHERE name = 'ACCOUNT_LEVEL_FEATURE_DEFAULTS' 
LIMIT 10;