class SendPasswordResetWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(user_id)
    user = User.find_by_id user_id
    Notifier.send_password_reset(user).deliver
  end
end
