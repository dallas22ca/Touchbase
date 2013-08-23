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
    if !"#{controller_name}##{action_name}".match current_user.allowed_actions
      redirect_to current_user.next_step
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
  
  def parse_criteria(resource)
    criteria = []
    
    if params[:filter_permalink]
      params[:filter_permalink].each_with_index do |permalink, index|
        search = params[:filter_search][index]
        
        unless search.blank?
          criteria.push [permalink, params[:filter_matcher][index], search]
        end
      end
    end
  
    @criteria = resource.criteria = criteria
  end

end
