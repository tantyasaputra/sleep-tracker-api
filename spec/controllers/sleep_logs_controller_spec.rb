require 'rails_helper'

RSpec.describe SleepLogsController, type: :controller do
  let!(:user) { create(:user, email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
  before do
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('test@example.com', 'password123')
  end

  describe "POST /sleep_logs/clock_in" do
    context "when user is not clocked in" do
      it "clocks in successfully" do
        post :clock_in

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['message']).to eq('successfully clocked in')
        expect(json['sleep_log']).to include('sleep_at')
        expect(json['sleep_log']['wake_at']).to be_nil
      end
    end

    context "when user is already clocked in" do
      before { post :clock_in }

      it "returns an error" do
        post :clock_in

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('you are already clocked in!')
      end
    end
  end

  describe "POST /sleep_logs/clock_out" do
    context "when user has clocked in" do
      before { post :clock_in }

      it "clocks out successfully" do
        post :clock_out

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['message']).to eq('successfully clocked out')
      end
    end

    context "when user has not clocked in" do
      it "returns an error" do
        post :clock_out

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('you have not clocked in!')
      end
    end
  end
end
