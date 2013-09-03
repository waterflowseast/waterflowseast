class VotingUpRelationshipAbility
  attr_reader :current_user, :voting_up_relationship

  def initialize(current_user, voting_up_relationship)
    @current_user = current_user
    @voting_up_relationship = voting_up_relationship
  end

  def create?

  end
end