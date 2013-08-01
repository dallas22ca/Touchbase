class Contact < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :user_id
  
  scope :pending, -> { where("pending_data != ''") }
  
  before_save :set_data, :sync_fields
  
  def set_data
    self.data ||= {}
    self.pending_data ||= {}
  end
  
  def ignore_pending_data
    update_attributes pending_data: nil
  end
  
  def sync_fields
    data.each do |k, v|
      field = user.fields.where(name: k.to_s).first
      data_type = Field::Formatter.detect(v)
      
      if field
        if field.data_type == "string" && data_type != "string"
          field.update_attributes data_type: data_type
        end
      else
        field = user.fields.create(name: k.to_s, data_type: data_type)
      end
    end
  end
  
  # %w[email address].each do |key|
  #   scope "has_#{key}", -> { |value| where("data @> hstore(?, ?)", key, value) }
  # 
  #   define_method(key) do
  #     data && data[key]
  #   end
  # 
  #   define_method("#{key}=") do |value|
  #     self.data = (data || {}).merge(key => value)
  #   end
  # end
end
