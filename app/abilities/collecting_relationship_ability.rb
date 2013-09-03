class CollectingRelationshipAbility
  attr_reader :current_user, :collecting_relationship

  def initialize(current_user, collecting_relationship)
    @current_user = current_user
    @collecting_relationship = collecting_relationship
  end

  def create?

  end

  def destroy?
    
  end
end