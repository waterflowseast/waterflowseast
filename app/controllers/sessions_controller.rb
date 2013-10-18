class SessionsController < ApplicationController
  before_filter :authenticate_no_user!, only: [:new, :create]

  def new
  end

  def create
    user = User.find_by_nickname(params[:login]) || User.find_by_email(params[:login].downcase)   

    if user and user.authenticate(params[:password])
      if user.confirmed?
        user.signin and sign_in user, params[:remember_me]
        redirect_to stored_location, notice: I18n.t('controller.session.sign_in', nickname: user.nickname)
      else
        redirect_to root_path, alert: I18n.t('controller.session.not_confirmed', nickname: user.nickname, email: user.email)
      end
    else
      flash.now[:alert] = I18n.t('controller.session.not_match')
      render :new
    end
  end

  def destroy
    sign_out
    redirect_to root_path, notice: I18n.t('controller.session.sign_out')
  end
end
