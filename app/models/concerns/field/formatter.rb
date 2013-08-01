class Field
  module Formatter
    extend ActiveSupport::Concern
    
    def self.detect(content)
      if content.to_i.to_s == content
        "integer"
      else
        "string"
      end
    end
  end
end