module Api
  module V1
    class ContactsController < ApplicationController
      respond_to :json

      def index
        respond_with @user.contacts.page(params[:page]).per_page(50)
      end

      def show
        respond_with @user.contacts.find(params[:id])
      end

      def create
        respond_with @user.import_from_array(params[:contacts])
      end

      def update
        respond_with @user.contacts.update(params[:id], params[:contact])
      end

      def destroy
        respond_with @user.contacts.destroy(params[:id])
      end
    end
  end
end