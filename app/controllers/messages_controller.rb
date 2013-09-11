class MessagesController < ApplicationController
  before_filter :authenticate_user!
  
  def destroy_multiple
    case params[:save]    
    when 'a_month'
      deleted_ids = current_user.messages.where("created_at < ?", 1.month.ago).pluck(:id)
      notice_message = I18n.t('controller.message.a_month')
    when 'a_week'
      deleted_ids = current_user.messages.where("created_at < ?", 1.week.ago).pluck(:id)
      notice_message = I18n.t('controller.message.a_week')
    when 'nothing'
      deleted_ids = current_user.messages.pluck(:id)
      notice_message = I18n.t('controller.message.nothing')
    else
      deleted_ids = []
      alert_message = I18n.t('controller.message.all')
    end

    current_user.destroy_messages(deleted_ids)

    if defined? notice_message
      redirect_to show_messages_user_path(current_user), notice: notice_message
    else
      redirect_to show_messages_user_path(current_user), alert: alert_message
    end
  end
end
