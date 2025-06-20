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
    return unless @resource.respond_to?(:audits)

    if @resource.accounts.empty?
      create_audit_without_account(action)
    else
      create_audit_with_accounts(action)
    end
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
