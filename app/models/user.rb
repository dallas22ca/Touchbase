class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
     
  has_many :contacts
  has_many :fields

  def save_contact(data, overwrite = false)
    warnings = []
    name = data.delete("name")
    contact = contacts.where(name: name).first
    
    if contact
      if data == contact.data
        warnings.push "#{contact.name} is an identical duplicate."
      else
        if overwrite || contact.new_record?
          contact.data = data
        else
          warnings.push "#{contact.name} has pending data."
          contact.pending_data = data
        end
      
        contact.save!
      end
    else
      contact = contacts.create!(name: name, data: data)
    end
    
    { warnings: warnings, contact: contact }
  end
end
