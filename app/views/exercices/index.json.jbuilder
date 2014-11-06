json.array!(@exercices) do |exercice|
  json.extract! exercice, :id, :name, :content, :equation, :weight, :solution, :star
  json.url exercice_url(exercice, format: :json)
end
