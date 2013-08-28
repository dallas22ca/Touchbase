module Api
  class ApplicationController < ActionController::Base
    skip_before_filter :verify_authenticity_token
    before_filter :restrict_access
    
  private
  
    def restrict_access
      if request.authorization.to_s =~ /token\=/
        authenticate_or_request_with_http_token do |api_token|
          @user = User.where(api_token: api_token).first
          @user
        end
      elsif request.authorization.to_s
        begin
          authenticate_or_request_with_http_basic do |email, password|
            @user = User.where(email: email).first
            @user && @user.valid_password?(password)
          end
        rescue
          render text: "404 Unauthenticated"
        end
      end
    end
  end
end