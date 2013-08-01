class ApplicationController < ActionController::Base
  before_filter :authenticate_user!, unless: :public?
  protect_from_forgery with: :exception
  
private

  def public?
    ["pages#show"].include? "#{controller_name}##{action_name}"
  end

end
