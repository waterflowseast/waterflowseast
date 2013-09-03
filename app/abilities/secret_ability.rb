class SecretAbility
  attr_reader :current_user, :secret

  def initialize(current_user, secret)
    @current_user = current_user
    @secret = secret
  end

  def create?

  end

  def destroy?

  end
end