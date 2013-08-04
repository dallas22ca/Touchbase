class UsersController < ApplicationController
  def update
    @user = current_user
    @user.update_attributes(user_params)
    redirect_to contacts_path
  end
  
private
  
  def user_params
    params.require(:user).permit(:file, :blob)
  end
end
