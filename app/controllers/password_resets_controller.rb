class PasswordResetsController < ApplicationController
  before_filter :check_email_format, only: :create
  before_filter :check_confirmed, only: :create

  before_filter :find_user, only: [:edit, :update]
  before_filter :check_time, only: [:edit, :update]

  def new
  end

  def create
    redirect_to root_path, notice: I18n.t('controller.password_reset.reset_now', email: params[:email], time_limit: EXTRA_CONFIG['reset_out_of_time_in_minutes'])
  end

  def edit
  end

  def update
    if @user.update_attributes params[:user].permit(:password, :password_confirmation)
      @user.reset_password
      @user.signin and sign_in @user
      redirect_to show_followings_user_path(@user), notice: I18n.t('controller.password_reset.just_reset')
    else
      render :edit
    end
  end

  private

  def check_email_format
    redirect_to new_password_reset_path, alert: I18n.t('controller.password_reset.invalid_format', email: params[:email]) unless params[:email] =~ Waterflowseast::Regex.email
  end

  def check_confirmed
    @user = User.find_by_email params[:email].downcase

    if @user
      if @user.confirmed?
        @user.send_password_reset
      else
        redirect_to root_path, alert: I18n.t('controller.password_reset.not_confirmed', email: params[:email])
      end
    end
  end

  def find_user
    @user = User.find_by_reset_token params[:id]
    redirect_to root_path, alert: I18n.t('controller.password_reset.user_not_exist') if @user.nil?
  end

  def check_time
    if @user.out_of_reset?
      @user.reset_password
      redirect_to new_password_reset_path, alert: I18n.t('controller.password_reset.out_of_time', time_limit: EXTRA_CONFIG['reset_out_of_time_in_minutes'])
    end
  end
end
