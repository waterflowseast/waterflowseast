class FollowingRelationshipAbility
  attr_reader :current_user, :following_relationship

  def initialize(current_user, following_relationship)
    @current_user = current_user
    @following_relationship = following_relationship
  end

  def create?

  end

  def destroy?

  end
end