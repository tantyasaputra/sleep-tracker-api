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

  describe "GET /sleep_logs/followings" do
    let(:friend) { create(:user) }

    before do
      user.follow!(friend)

      # Friend has some sleep logs
      create_list(:sleep_log, 5, user: friend, sleep_at: 3.days.ago, wake_at: 2.days.ago)
      create_list(:sleep_log, 2, user: friend, sleep_at: 10.days.ago, wake_at: 9.days.ago) # outside 7 days
    end

    it "returns sleep logs within default 7 days" do
      get :following

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json["data"].size).to eq(5)
      expect(json["meta"]["current_page"]).to eq(1)
      expect(json["meta"]["per_page"]).to eq(10)
      expect(json["meta"]["total_pages"]).to eq(1)
      expect(json["meta"]["total_count"]).to eq(5)

      # Check sleep log structure
      sleep_log = json["data"].first
      expect(sleep_log.keys).to contain_exactly("id", "type", "attributes")
    end

    it "returns empty if duration_days is very small" do
      get :following, params: { duration_days: 1 }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json["data"].size).to eq(0)
      expect(json["meta"]["total_count"]).to eq(0)
    end

    it "returns correct data structure" do
      get :following
      json = JSON.parse(response.body)

      expect(json.keys).to contain_exactly('data', 'meta')

      json['data'].each do |sleep_log|
        expect(sleep_log.keys).to contain_exactly('id', 'type', 'attributes')
        expect(sleep_log['type']).to eq('sleep_log')
        expect(sleep_log['attributes'].keys).to contain_exactly('sleep_at', 'wake_at', 'duration', 'user_id', 'email')
      end
    end

    it "paginates results correctly" do
      get :following, params: { per_page: 2, page: 2 }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json["data"].size).to eq(2) # page 2, 2 items per page
      expect(json["meta"]["current_page"]).to eq(2)
      expect(json["meta"]["per_page"]).to eq(2)
      expect(json["meta"]["total_pages"]).to eq(3) # 5 items => 3 pages if 2 per page
    end
  end

  describe "GET /sleep_logs" do
    before do
      create(:sleep_log, :with_no_wake_time, user: user, sleep_at: 1.days.ago)
      create_list(:sleep_log, 3, user: user, sleep_at: 2.days.ago, wake_at: 1.day.ago)
      create(:sleep_log, user: user, sleep_at: 10.days.ago, wake_at: 9.days.ago) # should be excluded
    end

    it 'returns sleep logs within duration_days filter and paginated' do
      get :index, params: {
        page: 1,
        per_page: 2,
        duration_days: 7,
        sort: '-sleep_at'
      }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json['data'].size).to eq(2)
      expect(json['meta']).to include(
                                'current_page' => 1,
                                'per_page' => 2,
                                'total_pages' => 2,
                                'total_count' => 4
                              )

      # check sorting order
      timestamps = json['data'].map { |d| d['attributes']['sleep_at'] }
      expect(timestamps).to eq(timestamps.sort.reverse) # descending
    end
  end
end
