json.partial! 'api/v1/models/account', formats: [:json], resource: @account
json.latest_kirvano_version @latest_kirvano_version
json.partial! 'enterprise/api/v1/accounts/partials/account', account: @account if KirvanoApp.enterprise?
