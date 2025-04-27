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

  describe 'GET #index' do
    before do
      request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('test@example.com', 'password123')
    end

    context "with default pagination" do
      before do
        create_list(:user, 15)
        get :index, format: :json
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns JSON with correct structure" do
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('data')
        expect(json_response).to have_key('meta')
      end

      it "returns users excluding current user" do
        json_response = JSON.parse(response.body)
        user_ids = json_response['data'].map { |user| user['id'] }
        expect(user_ids).not_to include(user.id)
      end
      #
      it "returns only id and email for each user" do
        json_response = JSON.parse(response.body)
        expect(json_response['data'].first.keys).to match_array([ 'id', 'email' ])
      end

      it "returns the correct pagination metadata" do
        json_response = JSON.parse(response.body)
        expect(json_response['meta']).to include(
                                           'current_page' => 1,
                                           'per_page' => 10,
                                           'total_pages' => 2,
                                           'total_count' => 15
                                         )
      end

      it "limits results to per_page value" do
        json_response = JSON.parse(response.body)
        expect(json_response['data'].length).to eq(10)
      end
    end
  end
end
