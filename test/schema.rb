ActiveRecord::Schema.define(:version => 0) do
  create_table :owners, :force => true do |t|
    t.string :name
    t.text :vimeo_api_key
    t.text :vimeo_api_secret
    t.text :vimeo_token
    t.text :vimeo_secret
    t.text :vimeo_id

  end
  create_table :videos, :force => true do |t|
    t.string :name
    t.integer :owner_id
  end
  add_column :videos, :vimeo_info, :blob
  add_column :videos, :vimeo_id, :string


end