require 'rails_helper'

RSpec.describe SleepLogSerializer do
  describe '#serializable_hash' do
    let(:user) { create(:user) }
    let(:sleep_log) { create(:sleep_log, user: user) }
    let(:serialized) { described_class.new(sleep_log).serializable_hash[:data][:attributes] }

    it 'includes the correct attributes' do
      expect(serialized).to include(
                              sleep_at: sleep_log.sleep_at,
                              wake_at: sleep_log.wake_at,
                              duration: sleep_log.duration,
                              user_id: user.id,
                              email: user.email
                            )
    end
  end
end
