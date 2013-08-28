class PagesController < ApplicationController
  def show
    permalink = params[:permalink]
    
    if user_signed_in?
      if current_user.step >= 4
        permalink ||= "dashboard"
      else
        permalink ||= "welcome"
      end
    end
    
    render permalink
  end
  
  def submit
    @permalink = params[:permalink]

    if @permalink == "book"
      dallas = User.where(email: "dallas@excitecreative.ca").first
      dallas.save_contact(params[:contact].merge({ overwrite: true })) if dallas
    end
  end
  
  def option
    @permalink = params[:permalink]
    
    if @permalink == "book"
      if params[:option] == "download"
        send_data "This is the book."
      end
    end
  end
end
