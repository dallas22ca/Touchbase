json.array!(@followups) do |followup|
  json.extract! followup, :followup_id, :date, :content, :complete
  json.url followup_url(followup, format: :json)
end
