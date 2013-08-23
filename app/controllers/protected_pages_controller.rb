class ProtectedPagesController < ApplicationController
  def show
    permalink = params[:permalink]
    
    if current_user.step >= 4
      permalink ||= "welcome"
    else
      permalink ||= "welcome"
    end
    
    if request.path == root_path
      if current_user.step >= 4
        redirect_to tasks_path
      else
        redirect_to protected_page_path(permalink)
      end
    else
      render permalink
    end
  end
end