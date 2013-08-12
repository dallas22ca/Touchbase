class Formatter
  
  def self.detect(field, content)
    # TODO: WHAT ABOUT A REGULAR DATE OR TIME?
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
        content = time_attempt.strftime("%B %-d, %Y")
      end
    end
    
    { data_type: data_type, content: content }
  end
  
  def self.format(data_type, content)
    Time.zone = "UTC"
    
    if data_type == "boolean"
      if ["true", "1", "t", "y", "yes"].include? content.to_s
        content = true.to_s
      else
        content = false.to_s
      end
    elsif data_type == "datetime"
      if content.class == ActiveSupport::TimeWithZone || content.class == Time
        content = content.strftime("%B %-d, %Y")
      else
        content = Chronic.parse(content).strftime("%B %-d, %Y")
      end
    elsif data_type == "integer"
      content = content.to_s.to_f.to_s.gsub(".0", "")
    else
      content = content.to_s
    end
    
    content
  end
end