class UsersController < ApplicationController
  def show
    @user = current_user
  end
  
  def update
    @user = current_user
    
    if params[:delete_file]
      @user.file.clear
      @user.save
      redirect_to new_contact_path
    else
      @user.update_attributes(user_params)
      redirect_to contacts_path
    end
  end
  
private
  
  def user_params
    params.require(:user).permit(:file, :blob, :delete_file)
  end
end
