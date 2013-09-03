class VotingDownRelationshipAbility
  attr_reader :current_user, :voting_down_relationship

  def initialize(current_user, voting_down_relationship)
    @current_user = current_user
    @voting_down_relationship = voting_down_relationship
  end

  def create?

  end
end