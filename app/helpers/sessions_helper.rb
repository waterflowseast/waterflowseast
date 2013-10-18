module SessionsHelper
  def sign_in(user, remember_me = false)
    expires_at = remember_me ? 2.weeks.from_now : 8.hours.from_now
    cookies[:remember_token] = { value: user.remember_token, expires: expires_at }
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

  def authenticate_no_user!
    redirect_to root_path, alert: I18n.t('helper.session.already_signed_in') if signed_in?
  end

  def store_location
    session[:return_to] = request.fullpath if request.get?
  end

  def stored_location
    session.delete(:return_to) || show_followings_user_path(current_user)
  end
end
