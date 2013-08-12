class ProtectedPagesController < ApplicationController
  def show
    permalink = params[:permalink]
    if current_user.step >= 4
      permalink ||= "dashboard"
      redirect_to contacts_path
    else
      permalink ||= "welcome"
      render permalink
    end
  end
end