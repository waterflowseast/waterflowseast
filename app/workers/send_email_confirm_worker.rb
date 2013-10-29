class SendEmailConfirmWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(user_id)
    user = User.find_by_id user_id
    Notifier.send_email_confirm(user).deliver
  end
end
