class ProtectedPagesController < ApplicationController
  def show
    permalink = params[:permalink]
    
    if current_user.step >= 4
      permalink ||= "welcome"
    else
      permalink ||= "welcome"
    end
    
    if request.path == root_path
      redirect_to protected_page_path("welcome")
    else
      render permalink
    end
  end
end