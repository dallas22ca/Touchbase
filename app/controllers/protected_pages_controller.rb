class ProtectedPagesController < ApplicationController
  def show
    permalink = params[:permalink]
    if current_user.step >= 4
      permalink ||= "dashboard"
    else
      permalink ||= "welcome"
    end
    render permalink
  end
end