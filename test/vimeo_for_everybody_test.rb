require 'test_helper'

class VimeoForEverybodyTest < ActiveSupport::TestCase

  def test_init
    Owner.new.vimeo
  end
    
end
