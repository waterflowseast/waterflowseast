class Admin::ApplicationController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authorize_admin!

  private

  def authorize_admin!
    redirect_to root_path, alert: I18n.t('controller.admin.application.admin_only') unless current_user.admin?
  end
end