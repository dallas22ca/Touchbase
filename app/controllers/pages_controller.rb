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
    tb = Tb.new(CONFIG["api_token"])
    tb.add_contacts(params[:contact], { overwrite: true })
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
