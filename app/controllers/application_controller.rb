class ApplicationController < ActionController::Base
  layout :choose_layout
  before_filter :authenticate_user!, unless: :public?
  before_filter :check_step, if: :user_signed_in?
  protect_from_forgery with: :exception
  
private

  def check_step
    if current_user.step <= 1
      if !"#{controller_name}##{action_name}".match(/contacts\#(new|create)|registrations|pages\#show/)
        redirect_to page_path("welcome")
      end
    elsif current_user.step <= 2
      if !"#{controller_name}##{action_name}".match(/fields\#(index|update)|registrations/)
        redirect_to fields_path
      end
    end
  end
  
  def public?
    ["pages#show", "users#timezone"].include? "#{controller_name}##{action_name}"
  end
  
  def choose_layout
    if !user_signed_in?
      "public"
    elsif ["contacts#index"].include?("#{controller_name}##{action_name}")
      @no_container = true
      "application"
    else
      "application"
    end
  end

end
