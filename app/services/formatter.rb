class Formatter
  
  def self.detect(content)
    if content.to_i.to_s == content
      "integer"
    else
      "string"
    end
  end
  
end