class Formatter
  
  def self.detect(field, content)
    # TODO: WHAT ABOUT A REGULAR DATE?
    data_type = "string"

    if [true, "true", "t"].include? content
      data_type = "boolean"
      content = true
    elsif [false, "false", "f"].include? content
      data_type = "boolean"
      content = false
    elsif content.to_s.to_i.to_s == content.to_s
      data_type = "integer"
    else
      if content.class == ActiveSupport::TimeWithZone || content.class == Time
        time_attempt = content
      else
        address_matcher = /(\d+)\s+([^\d]+)(.*)?(?:\w\w)\s+|(\w+)\s(\d+)$/
        time_attempt = Chronic.parse(content) if !content.match(address_matcher)
      end
    
      if time_attempt
        data_type = "datetime"
        content = time_attempt
      end
    end
    
    { data_type: data_type, content: content }
  end
  
end