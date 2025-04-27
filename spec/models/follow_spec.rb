require 'rails_helper'

RSpec.describe Follow, type: :model do
  describe "associations" do
    it { should belong_to(:follower).class_name('User') }
    it { should belong_to(:followed).class_name('User') }
  end

  describe "validations" do
    it "is valid with valid attributes" do
      follower = create(:user, email: 'follower@mail.com')
      followed = create(:user, email: 'followed@mail.com')
      follow = Follow.new(follower: follower, followed: followed)

      expect(follow).to be_valid
    end

    it "is not valid without a follower" do
      followed = create(:user, email: 'followed@mail.com')
      follow = Follow.new(follower: nil, followed: followed)

      expect(follow).not_to be_valid
    end

    it "is not valid without a followed user" do
      follower = create(:user, email: 'follower@mail.com')
      follow = Follow.new(follower: follower, followed: nil)

      expect(follow).not_to be_valid
    end

    it "does not allow duplicate follows" do
      follower = create(:user, email: 'follower@mail.com')
      followed = create(:user, email: 'followed@mail.com')

      Follow.create!(follower: follower, followed: followed)
      duplicate_follow = Follow.new(follower: follower, followed: followed)

      expect(duplicate_follow).not_to be_valid
    end
  end
end
