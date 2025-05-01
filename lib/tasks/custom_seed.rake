namespace :seed do
  desc "Seed users only"
  task users: :environment do
    load Rails.root.join("db/seeds/users.rb")
  end

  desc "Seed sleep logs only"
  task sleep_logs: :environment do
    load Rails.root.join("db/seeds/sleep_logs.rb")
  end
end
