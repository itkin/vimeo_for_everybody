ActiveRecord::Schema.define(:version => 0) do
  create_table :owners, :force => true do |t|
    t.string :name
    t.text :vimeo_api_key
    t.text :vimeo_api_secret
    t.text :vimeo_token
    t.text :vimeo_secret
    t.text :vimeo_id

  end
  create_table :movies, :force => true do |t|
    t.string :name
    t.integer :owner_id
    t.string :vimeo_id
    t.string :title
    t.text :description
    t.boolean :is_transcoding
  end
  add_column :movies, :vimeo_info_local, :blob
end