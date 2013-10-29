namespace :db do
  desc 'Create 30 regular users: foobar1 ~ foobar30, and 1 admin user: admin'
  task :sample_users => :environment do
    puts "creating users".center(100, '-') + "\n\n"

    1.upto(30) do |n|
      User.create(nickname: "foobar#{n}", email: "foobar#{n}@example.com", password: "foobar", password_confirmation: "foobar").confirm_email
    end

    admin = User.create(nickname: 'admin', email: 'admin@example.com', password: 'foobar', password_confirmation: 'foobar')
    admin.confirm_email
    admin.toggle! :admin

    User.update_all points_count: 5000
  end
end
