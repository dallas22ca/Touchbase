module Api
  class ApplicationController < ActionController::Base
    skip_before_filter :verify_authenticity_token
    before_filter :restrict_access
    
  private
  
    def restrict_access
      authenticate_or_request_with_http_token do |api_token, options|
        @user = User.where(api_token: api_token).first
        @user
      end
    end
  end
end