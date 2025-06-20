module Enterprise::DeviseOverrides::SessionsController
  def render_create_success
    create_audit_event('sign_in')
    super
  end

  def destroy
    create_audit_event('sign_out')
    super
  end

  def create_audit_event(action)
    return unless @resource

    # Usar try para verificar se audits está disponível de forma segura
    return unless @resource.try(:audits)

    if @resource.accounts.empty?
      create_audit_without_account(action)
    else
      create_audit_with_accounts(action)
    end
  rescue StandardError => e
    Rails.logger.error "Failed to create audit event: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end

  private

  def create_audit_without_account(action)
    @resource.audits.create(
      action: action,
      user_id: @resource.id,
      associated_id: nil,
      associated_type: nil
    )
  end

  def create_audit_with_accounts(action)
    associated_type = 'Account'
    @resource.accounts.each do |account|
      @resource.audits.create(
        action: action,
        user_id: @resource.id,
        associated_id: account.id,
        associated_type: associated_type
      )
    end
  end
end
