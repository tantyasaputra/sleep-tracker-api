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

      it "returns correct data structure" do
        json_response = JSON.parse(response.body)

        expect(json_response.keys).to contain_exactly('data', 'meta')

        json_response['data'].each do |user|
          expect(user.keys).to contain_exactly('id', 'type', 'attributes')
          expect(user['type']).to eq('user')
          expect(user['attributes'].keys).to contain_exactly('email')
        end
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

  describe 'POST #follow' do
    let!(:other_user) { create(:user, email: 'other@example.com', password: 'password123', password_confirmation: 'password123') }

    before do
      request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('test@example.com', 'password123')
    end

    context 'when following a valid user' do
      it 'follows the user and returns a success message' do
        post :follow, params: { id: other_user.id }
        expect(response.status).to eq(201)

        # Check the response JSON message
        expected_message = "successfully followed user #{other_user.email}"
        expect(JSON.parse(response.body)['message']).to eq(expected_message)

        expect(user.following?(other_user)).to be true
      end
    end

    context 'when trying to follow the same user' do
      it 'raises an error and does not follow' do
        user.follow!(other_user)

        post :follow, params: { id: other_user.id }

        # Check the error message (this assumes you have error handling set up in your controller)
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['error']).to eq("you have followed this person!")
      end
    end

    context 'when following a invalid user' do
      it 'follows the user and returns a success message' do
        post :follow, params: { id: 99999 }

        expect(response.status).to eq(404)
      end
    end
  end

  describe 'POST #unfollow' do
    let!(:other_user) { create(:user, email: 'other@example.com', password: 'password123', password_confirmation: 'password123') }

    before do
      user.follow!(other_user)
      request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('test@example.com', 'password123')
    end

    context 'when unfollowing a user' do
      it 'unfollows the user and returns a success message' do
        post :unfollow, params: { id: other_user.id }

        expect(response.status).to eq(201)

        expected_message = "successfully unfollowed user #{other_user.email}"
        expect(JSON.parse(response.body)['message']).to eq(expected_message)
        expect(user.following?(other_user)).to be false
      end
    end

    context 'when trying to unfollow a user not followed' do
      it 'raises an error and does not unfollow' do
        user.unfollow!(other_user)
        # Try to unfollow a user that the current_user is not following
        post :unfollow, params: { id: other_user.id }

        # Check the error message (you should handle this case in your controller)
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['error']).to eq("you are not following this person!")
      end
    end

    context 'when unfollowing a invalid user' do
      it 'follows the user and returns a success message' do
        post :unfollow, params: { id: 99999 }
        expect(response.status).to eq(404)
      end
    end
  end
end
