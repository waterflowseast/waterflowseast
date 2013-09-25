class EmailConfirmController < ApplicationController
  before_filter :find_user
  before_filter :check_confirmed
  before_filter :check_time

  def new
  end

  def create
    @user.confirm_email
    sign_in @user
    redirect_to show_followings_user_path(@user), notice: I18n.t("controller.email_confirm.just_confirmed", email: @user.email)
  end

  private

  def find_user
    @user = User.find_by_confirm_token params[:confirm_token]
    redirect_to root_path, alert: I18n.t('controller.email_confirm.user_not_exist') if @user.nil?
  end

  def check_confirmed
    redirect_to root_path, alert: I18n.t('controller.email_confirm.confirmed') if @user.confirmed?
  end

  def check_time
    redirect_to root_path, alert: I18n.t('controller.email_confirm.out_of_time', email: @user.email, time_limit: EXTRA_CONFIG['confirm_out_of_time_in_hours']) if @user.out_of_confirm?
  end
end
