class Formatter
  
  def self.detect(field, content)
    # TODO: WHAT ABOUT A REGULAR DATE?
    data_type = "string"

    if ["true", "1", "t", "y", "yes"].include? content.to_s
      data_type = "boolean"
      content = true
    elsif ["false", "0", "f", "n", "no"].include? content.to_s
      data_type = "boolean"
      content = false
    elsif content.class == ActiveSupport::TimeWithZone || content.class == Time
      data_type = "datetime"
    elsif content.to_s.match /^-{0,1}\d*\.{0,1}\d+$/
      data_type = "integer"
    else
      address_matcher = /(\d+)\s+([^\d]+)(.*)?(?:\w\w)\s+|(\w+)\s(\d+)$/
      time_attempt = Chronic.parse(content) if !content.to_s.match(address_matcher)
    
      if time_attempt
        data_type = "datetime"
        content = time_attempt
      end
    end
    
    { data_type: data_type, content: content }
  end
  
end