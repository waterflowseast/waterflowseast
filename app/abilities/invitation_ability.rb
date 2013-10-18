class InvitationAbility
  attr_reader :current_user, :invitation

  def initialize(current_user, invitation)
    @current_user = current_user
    @invitation = invitation
  end

  def create?
    points_cost = POINTS_CONFIG['invite'].abs
    return AbilityResult.new(false, I18n.t('ability.invitation.short_of_points', count: points_cost)) if current_user.points_count < points_cost

    email = invitation.receiver_email
    return AbilityResult.new(false, I18n.t('ability.invitation.has_been_invited', email: email)) if Invitation.find_by_receiver_email(email)

    if User.find_by_email(email)
      AbilityResult.new(false, I18n.t('ability.invitation.has_been_signed_up', email: email))
    else
      AbilityResult.new(true)
    end
  end
end
