FactoryBot.define do
  factory :sleep_log do
    user
    sleep_at { Time.current - 1.hour }
    wake_at { Time.current }
    duration { wake_at - sleep_at }

    trait :with_no_wake_time do
      wake_at { nil }
    end

    trait :with_duration do
      sleep_at { Time.current - 2.hours }
      wake_at { Time.current - 1.hour }
      duration { wake_at - sleep_at }
    end
  end
end
