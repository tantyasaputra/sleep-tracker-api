# bin/rake seed:users
require 'bcrypt'

start_time = Time.now
hashed_password = BCrypt::Password.create('password123')
user_size = 1000
users = []


user_size.times do |i|
  users << {
    email: "user#{i}@example.com",
    password_digest: hashed_password,
  }
end

User.insert_all(users)

puts "successfully seeds #{user_size} user within #{Time.now - start_time} seconds"