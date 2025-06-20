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

    # Para SuperAdmin e outros usuários sem contas associadas
    if @resource.accounts.empty?
      @resource.audits.create(
        action: action,
        user_id: @resource.id,
        associated_id: nil,
        associated_type: nil
      )
    else
      # Para usuários normais com contas associadas
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
end
