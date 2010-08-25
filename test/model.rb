class Owner < ActiveRecord::Base
  has_vimeo_account
  has_many :videos
end

class Video < ActiveRecord::Base
  has_vimeo_instance :vimeo_account_belongs_to => :owner
  belongs_to :owner
end