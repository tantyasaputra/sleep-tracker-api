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

  describe "following relationships" do
    let(:user) { create(:user, email: 'user@example.com') }
    let(:other_user) { create(:user, email: 'other@example.com') }

    it "can follow another user" do
      expect {
        user.follow!(other_user)
      }.to change { user.following.count }.by(1)

      expect(user.following?(other_user)).to be true
      expect(other_user.followers).to include(user)
    end

    it "can unfollow a followed user" do
      user.follow!(other_user)
      expect(user.following?(other_user)).to be true

      expect {
        user.unfollow!(other_user)
      }.to change { user.following.count }.by(-1)

      expect(user.following?(other_user)).to be false
    end

    it "can re-follow another user" do
      user.follow!(other_user)
      user.unfollow!(other_user)

      expect {
        user.follow!(other_user)
      }.to change { user.following.count }.by(1)

      expect(user.following?(other_user)).to be true
      expect(other_user.followers).to include(user)
    end

    it "does not allow following self" do
      expect {
        user.follow!(user)
      }.not_to change { user.following.count }

      expect(user.following?(user)).to be false
    end

    it "does not duplicate follows" do
      user.follow!(other_user)
      expect {
        user.follow!(other_user)
      }.not_to change { user.following.count }
    end
  end

  describe "#soft_delete_follows" do
    let(:user) { create(:user, email: 'user@example.com') }
    let(:other_user) { create(:user, email: 'other@example.com') }

    before do
      user.follow!(other_user)
    end

    it "soft deletes follow relationships when the user is soft deleted" do
      follow = Follow.find_by(follower_id: user.id, followed_id: other_user.id)
      expect(follow.deleted_at).to be_nil

      # Soft delete the follower
      user.destroy

      follow.reload
      expect(follow.deleted_at).not_to be_nil
    end

    it "does not affect other follows when a user is soft deleted" do
      another_user = create(:user, email: 'another_user@example.com')
      other_user.follow!(another_user)

      # Soft delete the original follower
      user.destroy

      # Check that the new follow is not deleted
      follow = Follow.find_by(follower_id: other_user.id, followed_id: another_user.id)
      expect(follow.deleted_at).to be_nil
    end
  end
end
