class MessageAbility
  attr_reader :current_user, :message

  def initialize(current_user, message)
    @current_user = current_user
    @message = message
  end

  def destroy?
    if current_user == message.user
      AbilityResult.new(true)
    else
      AbilityResult.new(false, I18n.t('ability.message.wrong_user'))
    end
  end
end