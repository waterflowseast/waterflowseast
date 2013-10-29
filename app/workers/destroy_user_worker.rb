class DestroyUserWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(user_id)
    user = User.find_by_id user_id

    user.destroy_self
  end
end
