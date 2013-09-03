class InvitationController
  attr_reader :current_user, :invitation

  def initialize(current_user, invitation)
    @current_user = current_user
    @invitation = invitation
  end

  def create?

  end
end