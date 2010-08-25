ActiveRecord::Schema.define(:version => 0) do
  create_table :owners, :force => true do |t|
    t.string :name
    t.text :vimeo_api_key
    t.text :vimeo_api_secret
    t.text :vimeo_token
    t.text :vimeo_secret

  end
  create_table :videos, :force => true do |t|
    t.string :name
    t.integer :user_id
  end
  add_column :videos, :description, :text
  add_column :videos, :embed, :text
  add_column :videos, :video_id, :string


end