class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
     
  has_many :contacts
  has_many :fields

  def save_contact(data, overwrite = false)
    warnings = []
    name = data.delete("name")
    contact = contacts.where(name: name).first
    
    data.each do |k, v|
      formatter = Formatter.detect(k.to_s, v)
      data_type = formatter[:data_type]
      content = formatter[:content]
      data[k.to_s] = content
    end
    
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
