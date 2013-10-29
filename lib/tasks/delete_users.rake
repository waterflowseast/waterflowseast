namespace :db do
  desc "Delete users who didn't confirm in time or users who haven't signed in for three months"
  task :delete_users => :environment do
    # ---------------- delete users who didn't confirm in time ----------------
    ids = User.where(signed_up_confirmed_at: nil).where("created_at < ?", EXTRA_CONFIG['confirm_out_of_time_in_hours'].hours.ago).pluck(:id)
    User.delete ids

    # ---------------- delete users who haven't signed in for three months ----------------
    User.where("signed_up_confirmed_at IS NOT NULL").where("last_signed_in_at < ?", 3.months.ago).each do |user|
      if (! user.admin?) and (user.great_posts_count == 0)
        user.destroy_self
        sleep 10
      end
    end
  end
end
