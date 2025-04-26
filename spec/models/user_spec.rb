require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with a unique email' do
      user = create(:user)
      expect(user).to be_valid
    end

    it 'is invalid without an email' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'is invalid with a duplicate email' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'test@example.com')

      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('has already been taken')
    end
  end

  describe '#destroy (soft delete)' do
    let!(:user) { create(:user) }

    it 'marks the user as deleted' do
      expect(user.deleted_at).to be_nil

      user.destroy
      user.reload

      expect(user.deleted_at).not_to be_nil
    end

    it 'does not actually remove user and follows from the database' do
      expect { user.destroy }.not_to change(User, :count)
    end
  end
end
