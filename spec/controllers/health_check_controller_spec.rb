
require 'rails_helper'

RSpec.describe HealthCheckController, type: :controller do
  describe 'GET /health_check/up' do
    it 'returns a 200 OK status' do
      get :up
      expect(response).to have_http_status(:ok)
    end

    it 'returns plain text with "server is OK"' do
      get :up
      expect(response.content_type).to eq 'text/plain; charset=utf-8'
      expect(response.body).to match(/server is OK [A-Z]{8}/)
    end
  end
end
