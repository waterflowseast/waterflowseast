class UserAbility
  attr_reader :current_user, :user

  def initialize(current_user, user)
    @current_user = current_user
    @user = user
  end

  def show_received_secrets?
    
  end

  def show_sent_secrets?
    
  end

  def show_messages?
    
  end

  def show_sent_invitations?
    
  end

  def update_words?
    
  end

  def update_avatar?
    
  end

  def update_password?
    
  end

  def destroy?
    
  end
end