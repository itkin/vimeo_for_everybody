class Owner < ActiveRecord::Base
  has_many :movies, :hosted_on => :vimeo
end

class Movie < ActiveRecord::Base
  hosted_on_vimeo :account => :owner, :players => {:default => { :width => 200, :height => 200 } } 
  belongs_to :owner
end