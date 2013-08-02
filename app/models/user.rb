class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
     
  has_many :contacts
  has_many :fields
  
  def save_contact(args = {})
    name = args.delete(:name)
    c = contacts.where(name: name).first
    
    if c
      c.update_attributes args
    else
      c = contacts.create(name: name, data: args[:data])
    end

    c
  end
end
