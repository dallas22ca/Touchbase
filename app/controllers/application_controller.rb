class ApplicationController < ActionController::Base
  layout :choose_layout
  before_filter :authenticate_user!, unless: :public?
  protect_from_forgery with: :exception
  
private

  def public?
    ["pages#show"].include? "#{controller_name}##{action_name}"
  end
  
  def choose_layout
    if ["contacts#index"].include?("#{controller_name}##{action_name}")
      "application"
    else
      "public"
    end
  end

end
