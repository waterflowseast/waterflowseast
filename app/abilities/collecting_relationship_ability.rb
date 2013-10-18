class CollectingRelationshipAbility
  attr_reader :current_user, :collecting_relationship

  def initialize(current_user, collecting_relationship)
    @current_user = current_user
    @collecting_relationship = collecting_relationship
  end

  def create?
    points_cost = POINTS_CONFIG['collect'].abs
    return AbilityResult.new(false, I18n.t('ability.collecting_relationship.short_of_points', count: points_cost)) if current_user.points_count < points_cost

    post = collecting_relationship.post
    return AbilityResult.new(false, I18n.t('ability.collecting_relationship.can_not_collect_your_own')) if current_user == post.user

    if current_user.has_collected? post
      AbilityResult.new(false, I18n.t('ability.collecting_relationship.has_collected'))
    else
      AbilityResult.new(true)
    end
  end

  def destroy?
    if current_user == collecting_relationship.user
      AbilityResult.new(true)
    else
      AbilityResult.new(false, I18n.t('ability.collecting_relationship.wrong_user'))
    end
  end
end
