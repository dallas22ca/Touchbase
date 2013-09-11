json.array!(@pages) do |page|
  json.extract! page, :website_id, :title, :permalink
  json.url page_url(page, format: :json)
end
