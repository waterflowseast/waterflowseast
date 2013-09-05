class CommentAbility
  attr_reader :current_user, :comment

  def initialize(current_user, comment)
    @current_user = current_user
    @comment = comment
  end

  def create?
    points_cost = POINTS_CONFIG['comment'].abs
    if current_user.points_count >= points_cost
      AbilityResult.new(true)
    else
      AbilityResult.new(false, I18n.t('ability.comment.short_of_points', count: points_cost))
    end
  end

  def update?
    return AbilityResult.new(true) if current_user.admin?
    return AbilityResult.new(false, I18n.t('ability.comment.wrong_user')) if current_user != comment.user

    if comment.created_at > 1.hour.ago
      AbilityResult.new(true)
    else
      AbilityResult.new(false, I18n.t('ability.comment.out_of_time'))
    end
  end

  def destroy?
    return AbilityResult.new(false, I18n.t('ability.comment.can_not_be_deleted')) unless comment.can_be_deleted?

    if current_user.admin? or current_user == comment.user
      AbilityResult.new(true)
    else
      AbilityResult.new(false, I18n.t('ability.comment.not_authorized_to_delete'))
    end
  end
end