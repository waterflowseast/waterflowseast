class FollowingRelationshipAbility
  attr_reader :current_user, :following_relationship

  def initialize(current_user, following_relationship)
    @current_user = current_user
    @following_relationship = following_relationship
  end

  def create?
    points_cost = POINTS_CONFIG['follow'].abs
    return AbilityResult.new(false, I18n.t('ability.following_relationship.short_of_points', count: points_cost)) if current_user.points_count < points_cost

    followed = following_relationship.followed
    return AbilityResult.new(false, I18n.t('ability.following_relationship.can_not_follow_self')) if current_user == followed

    if current_user.has_followed? followed
      AbilityResult.new(false, I18n.t('ability.following_relationship.has_followed'))
    else
      AbilityResult.new(true)
    end
  end

  def destroy?
    if current_user == following_relationship.follower
      AbilityResult.new(true)
    else
      AbilityResult.new(false, I18n.t('ability.following_relationship.wrong_user'))
    end
  end
end