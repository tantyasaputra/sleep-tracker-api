require 'rails_helper'

RSpec.describe UserSerializer do
  describe '#serializable_hash' do
    let(:user) { create(:user, email: 'user@example.com') }
    let(:serialized) { described_class.new(user).serializable_hash[:data][:attributes] }

    it 'includes the email attribute' do
      expect(serialized).to eq(email: 'user@example.com')
    end
  end
end
