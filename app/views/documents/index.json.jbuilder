json.array!(@documents) do |document|
  json.extract! document, :name, :body, :extension
  json.url document_url(document, format: :json)
end
