class ApplicationController < ActionController::Base
  layout :choose_layout
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :authenticate_user!, unless: :public?
  before_filter :check_step, if: :user_signed_in?
  before_filter :set_timezone
  protect_from_forgery with: :exception
  
protected

  def set_timezone
    if user_signed_in?
      Time.zone = current_user.time_zone
    else
      Time.zone = "Atlantic Time (Canada)"
    end
  end

  def check_step
    if current_user.step <= 1
      if !"#{controller_name}##{action_name}".match(/contacts\#(new|create)|sessions|registrations|pages\#show/)
        redirect_to protected_page_path("welcome")
      end
    elsif current_user.step <= 2
      if current_user.has_deletable_pending_import?
        if !"#{controller_name}##{action_name}".match(/fields\#(index|update)|contacts\#(new|create)|sessions|registrations|pages\#show/)
          redirect_to fields_path
        end
      else
        if !"#{controller_name}##{action_name}".match(/contacts\#(new|create)|sessions|registrations|pages\#show/)
          redirect_to new_contact_path
        end
      end
    elsif current_user.step <= 3
      if !"#{controller_name}##{action_name}".match(/followups|fields\#(index|update)|contacts\#(new|create)|sessions|registrations|pages\#show/)
        redirect_to followups_path
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
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:name, :email, :password) }
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:name, :email, :password, :time_zone) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:name, :email, :password, :password_confirmation, :current_password, :time_zone) }
  end

end
