class UserAbility
  attr_reader :current_user, :user

  def initialize(current_user, user)
    @current_user = current_user
    @user = user
  end

  def show_private?
    if current_user == user
      AbilityResult.new(true)
    else
      AbilityResult.new(false, I18n.t('ability.user.not_authorized_to_show'))
    end
  end

  def update_private?
    if current_user == user
      AbilityResult.new(true)
    else
      AbilityResult.new(false, I18n.t('ability.user.not_authorized_to_update'))
    end
  end

  def destroy?
    return AbilityResult.new(false, I18n.t('ability.user.can_not_be_deleted')) unless user.can_be_deleted?
    return AbilityResult.new(false, I18n.t('ability.user.can_not_delete_admin')) if user.admin?

    if current_user.admin? or current_user == user
      AbilityResult.new(true)
    else
      AbilityResult.new(false, I18n.t('ability.comment.not_authorized_to_delete'))
    end
  end
end