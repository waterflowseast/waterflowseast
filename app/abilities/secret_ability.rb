class SecretAbility
  attr_reader :current_user, :secret

  def initialize(current_user, secret)
    @current_user = current_user
    @secret = secret
  end

  def create?
    points_cost = secret.points_cost
    return AbilityResult.new(false, I18n.t('ability.secret.short_of_points', count: points_cost)) if current_user.points_count < points_cost

    if current_user == secret.receiver
      AbilityResult.new(false, I18n.t('ability.secret.can_not_send_to_self'))
    else
      AbilityResult.new(true)
    end
  end

  def destroy?
    if current_user.has_secret? secret
      AbilityResult.new(true)
    else
      AbilityResult.new(false, I18n.t('ability.secret.wrong_user'))
    end
  end
end
