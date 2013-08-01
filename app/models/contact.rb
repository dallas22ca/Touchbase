class Contact < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :user_id
  
  scope :pending, -> { where("pending_data != ''") }
  
  before_save :set_data
  
  def set_data
    self.data ||= {}
    self.pending_data ||= {}
  end
  
  def ignore_pending_data
    update_attributes pending_data: nil
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
