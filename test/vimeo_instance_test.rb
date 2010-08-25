require 'test_helper'

class VimeoInstanceTest < ActiveSupport::TestCase

  def test_init
    assert Video.methods.detect{|m| m.match(/init_from_vimeo/) }
  end

end
