class VotingDownRelationshipAbility
  attr_reader :current_user, :voting_down_relationship

  def initialize(current_user, voting_down_relationship)
    @current_user = current_user
    @voting_down_relationship = voting_down_relationship
  end

  def create?
    points_cost = POINTS_CONFIG['vote_down'].abs
    return AbilityResult.new(false, I18n.t('ability.voting_down_relationship.short_of_points', count: points_cost)) if current_user.points_count < points_cost

    votable = voting_down_relationship.votable
    return AbilityResult.new(false, I18n.t('ability.voting_down_relationship.can_not_vote_your_own')) if current_user == votable.user

    if current_user.has_voted? votable
      AbilityResult.new(false, I18n.t('ability.voting_down_relationship.has_voted'))
    else
      AbilityResult.new(true)
    end
  end
end
