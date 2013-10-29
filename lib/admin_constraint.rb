class AdminConstraint
  def matches?(request)
    return false unless request.cookies['remember_token']
    user = User.find_by_remember_token request.cookies['remember_token']
    user && user.admin?
  end
end
