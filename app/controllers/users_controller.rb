class UsersController < ApplicationController
  def show
    @user = current_user
  end
  
  def update
    @user = current_user
    @user.update_attributes(user_params)
    redirect_to contacts_path
  end
  
private
  
  def user_params
    params.require(:user).permit(:file, :blob, :delete_file)
  end
end
