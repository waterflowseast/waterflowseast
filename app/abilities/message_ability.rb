class MessageAbility
  attr_reader :current_user, :message

  def initialize(current_user, message)
    @current_user = current_user
    @message = message
  end

  def destroy?

  end
end