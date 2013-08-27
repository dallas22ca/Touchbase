module Api
  class ApplicationController < ActionController::Base
    skip_before_filter :verify_authenticity_token
    before_filter :restrict_access
    
  private
  
    def restrict_access
      if request.authorization.to_s[/^Token /]
        authenticate_or_request_with_http_token do |api_token, options|
          @user = User.where(api_token: api_token).first
          @user
        end
      else
        authenticate_or_request_with_http_basic do |email, password|
          @user = User.where(email: email).first
          if @user && @user.valid_password?(password)
            sign_in :user, @user
          end
        end
      end
    end
  end
end