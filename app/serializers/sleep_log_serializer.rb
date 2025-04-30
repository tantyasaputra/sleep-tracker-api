class SleepLogSerializer
  include JSONAPI::Serializer

  attributes :sleep_at, :wake_at, :duration, :user_id
  attribute :email do |object|
    object.user&.email
  end
end
