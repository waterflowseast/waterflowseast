class SecretsController < ApplicationController
  before_filter :authenticate_user!

  before_filter :find_receiver_via_permalink, only: :new

  before_filter :find_receiver_via_id, only: :create
  before_filter :authorize_create!, only: :create

  before_filter :find_secret, only: :destroy
  before_filter :authorize_destroy!, only: :destroy

  def new
    @secret = current_user.secrets.build receiver_id: @receiver.id
  end

  def create
    if @secret.save
      current_user.secret_has_been_sent_to(@receiver)
      redirect_to show_sent_secrets_user_path(current_user), notice: I18n.t('controller.secret.just_sent', nickname: @receiver.nickname)
    else
      render :new
    end
  end

  def destroy
    if current_user == @secret.sender
      current_user.destroy_sent_secret(@secret)
      redirect_to show_sent_secrets_user_path(current_user), notice: I18n.t('controller.secret.sent_secret_destroyed', nickname: @secret.receiver.nickname)
    else
      current_user.destroy_received_secret(@secret)
      redirect_to show_received_secrets_user_path(current_user), notice: I18n.t('controller.secret.received_secret_destroyed', nickname: @secret.sender.nickname)
    end
  end

  private

  def find_receiver_via_permalink
    @receiver = User.find_by_permalink params[:receiver]
    redirect_to show_sent_secrets_user_path(current_user), alert: I18n.t('controller.secret.receiver_not_exist') if @receiver.nil?
  end

  def find_receiver_via_id
    @receiver = User.find_by_id params[:secret][:receiver_id]
    redirect_to show_sent_secrets_user_path(current_user), alert: I18n.t('controller.secret.receiver_not_exist') if @receiver.nil?
  end

  def authorize_create!
    @secret = current_user.secrets.build params[:secret].permit(:receiver_id, :content)
    ability_result = can? :create, @secret, false
    redirect_to show_sent_secrets_user_path(current_user), alert: ability_result.description unless ability_result.result
  end

  def find_secret
    @secret = Secret.find_by_id params[:id]
    redirect_to show_received_secrets_user_path(current_user), alert: I18n.t('controller.secret.record_not_exist') if @secret.nil?
  end

  def authorize_destroy!
    ability_result = can? :destroy, @secret, false
    redirect_to show_received_secrets_user_path(current_user), alert: ability_result.description unless ability_result.result
  end
end
