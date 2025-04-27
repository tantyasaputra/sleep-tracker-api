require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  # Create a user with a known email and password
  let!(:user) { create(:user, email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }

  describe 'GET #profiles' do
    context 'with valid credentials' do
      before do
        other_user1 = create(:user, email: 'other_user1@example.com')
        other_user2 = create(:user, email: 'other_user2@example.com')
        other_user3 = create(:user, email: 'other_user3@example.com')

        # Following two people
        user.follow!(other_user1)
        user.follow!(other_user2)

        # Followed by one person
        other_user3.follow!(user)
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('test@example.com', 'password123')
        get :profiles
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:success)
      end

      it 'returns the current user email' do
        expect(JSON.parse(response.body)['email']).to eq(user.email)
      end

      it 'returns the current user following' do
        expect(JSON.parse(response.body)['following']).to eq(2)
      end

      it 'returns the current user followers' do
        expect(JSON.parse(response.body)['followers']).to eq(1)
      end
    end

    context 'with invalid credentials' do
      before do
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('test@example.com', 'wrongpassword')
        get :profiles
      end

      it 'returns an unauthorized response' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an authentication error message' do
        expect(JSON.parse(response.body)['error']).to eq('invalid password!')
      end
    end

    context 'with non-existent user' do
      before do
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('nonexistent@example.com', 'password123')
        get :profiles
      end

      it 'returns an unauthorized response' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an authentication error message' do
        expect(JSON.parse(response.body)['error']).to eq('invalid user!')
      end
    end
  end
end
