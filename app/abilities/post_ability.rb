class PostAbility
  attr_reader :current_user, :post

  def initialize(current_user, post)
    @current_user = current_user
    @post = post
  end

  def create?
    points_cost = post.points_cost
    if current_user.points_count >= points_cost
      AbilityResult.new(true)
    else
      AbilityResult.new(false, I18n.t('ability.post.short_of_points', count: points_cost))
    end
  end

  def update_except_for_content?
    if current_user.admin? or (current_user == post.user)
      AbilityResult.new(true)
    else
      AbilityResult.new(false, I18n.t('ability.post.not_authorized_to_update'))
    end
  end

  def update_content?
    return AbilityResult.new(true) if current_user.admin?
    return AbilityResult.new(false, I18n.t('ability.post.wrong_user')) if current_user != post.user

    time_limit = EXTRA_CONFIG['post_out_of_time_in_hours']
    if post.created_at > time_limit.hours.ago
      AbilityResult.new(true)
    else
      AbilityResult.new(false, I18n.t('ability.post.out_of_time', time_limit: time_limit))
    end
  end

  def destroy?
    return AbilityResult.new(false, I18n.t('ability.post.can_not_be_deleted')) unless post.can_be_deleted?
    return AbilityResult.new(true) if current_user.admin?
    return AbilityResult.new(false, I18n.t('ability.post.not_authorized_to_delete')) if current_user != post.user

    points_cost = POINTS_CONFIG['delete_post'].abs
    if current_user.points_count < points_cost
      AbilityResult.new(false, I18n.t('ability.post.short_of_points_to_delete', count: points_cost))
    else
      AbilityResult.new(true)
    end
  end
end
