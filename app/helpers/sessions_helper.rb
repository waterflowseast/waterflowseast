module SessionsHelper
  def sign_in(user, permanent = false)
    if permanent
      cookies.permanent[:remember_token] = user.remember_token
    else
      cookies[:remember_token] = user.remember_token
    end

    self.current_user = user
  end

  def sign_out
    cookies.delete :remember_token
    self.current_user = nil
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= User.find_by_remember_token cookies[:remember_token]
  end

  def current_user?(user)
    user == current_user
  end

  def signed_in?
    ! current_user.nil?
  end

  def authenticate_user!
    unless signed_in?
      store_location
      redirect_to signin_path, alert: I18n.t('helper.session.sign_in_first')
    end
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def stored_location
    session.delete(:return_to) || show_followings_user_path(current_user)
  end
end
