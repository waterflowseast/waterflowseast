class CommentAbility
  attr_reader :current_user, :comment

  def initialize(current_user, comment)
    @current_user = current_user
    @comment = comment
  end

  def create?
    points_cost = POINTS_CONFIG['comment'].abs
    return AbilityResult.new(false, I18n.t('ability.comment.short_of_points', count: points_cost)) if current_user.points_count < points_cost

    if comment.too_deep?
      AbilityResult.new(false, I18n.t('ability.comment.too_deep'))
    else
      AbilityResult.new(true)
    end
  end

  def update?
    return AbilityResult.new(true) if current_user.admin?
    return AbilityResult.new(false, I18n.t('ability.comment.wrong_user')) if current_user != comment.user

    time_limit = EXTRA_CONFIG['comment_out_of_time_in_minutes']
    if comment.created_at > time_limit.minutes.ago
      AbilityResult.new(true)
    else
      AbilityResult.new(false, I18n.t('ability.comment.out_of_time', time_limit: time_limit))
    end
  end

  def destroy?
    return AbilityResult.new(true) if current_user.admin?
    return AbilityResult.new(false, I18n.t('ability.comment.not_authorized_to_delete')) if current_user != comment.user

    points_cost = POINTS_CONFIG['delete_comment'].abs
    if current_user.points_count < points_cost
      AbilityResult.new(false, I18n.t('ability.comment.short_of_points_to_delete', count: points_cost))
    else
      AbilityResult.new(true)
    end
  end
end
