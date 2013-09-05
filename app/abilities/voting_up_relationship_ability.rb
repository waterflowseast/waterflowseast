class VotingUpRelationshipAbility
  attr_reader :current_user, :voting_up_relationship

  def initialize(current_user, voting_up_relationship)
    @current_user = current_user
    @voting_up_relationship = voting_up_relationship
  end

  def create?
    points_cost = POINTS_CONFIG['vote_up'].abs
    return AbilityResult.new(false, I18n.t('ability.voting_up_relationship.short_of_points', count: points_cost)) if current_user.points_count < points_cost

    votable = voting_up_relationship.votable
    return AbilityResult.new(false, I18n.t('ability.voting_up_relationship.can_not_vote_your_own')) if current_user == votable.user

    if current_user.has_voted? votable
      AbilityResult.new(false, I18n.t('ability.voting_up_relationship.has_voted'))
    else
      AbilityResult.new(true)
    end
  end
end