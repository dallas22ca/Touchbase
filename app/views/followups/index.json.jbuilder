json.array!(@followups) do |followup|
  json.extract! followup, :user_id, :criteria, :description, :date, :date_offset, :recurring
  json.url followup_url(followup, format: :json)
end
