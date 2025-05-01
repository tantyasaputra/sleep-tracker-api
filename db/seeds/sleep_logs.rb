# bin/rake seed:sleep_logs.rb

puts "Start seeding sleep_logs"
user_ids = User.pluck(:id).limit(5)

logs_size = 10_000
user_ids.each_with_index do |user_id, index|
  logs = []

  logs_size.times do
    sleep_at = rand(0..30).days.ago + rand(0..23).hours + rand(0..59).minutes
    wake_at = sleep_at + rand(1..12).hours
    duration = ((wake_at - sleep_at) / 60).to_i

    logs << {
      user_id: user_id,
      sleep_at: sleep_at,
      wake_at: wake_at,
      duration: duration,
      created_at: Time.current,
      updated_at: Time.current
    }
  end

  logs.each_slice(200) do |batch|
    SleepLog.insert_all(batch)
  end

  puts "Seeded #{logs_size} logs for user ##{index + 1}/#{user_ids.size}"
end
