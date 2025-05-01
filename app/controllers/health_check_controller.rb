class HealthCheckController < ApplicationController
  skip_before_action :authenticate!

  def up
    rand_string = (0...8).map { rand(65..90).chr }.join
    render plain: "server is OK #{rand_string}"
  end
end
