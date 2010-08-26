require 'test_helper'

class VimeoInstanceTest < ActiveSupport::TestCase

  def test_init
    assert Video.methods.detect{|m| m.match(/init_from_vimeo/) }
  end

  def test_vimeo_info
    video = Video.new(:vimeo_id => 12)
    video.vimeo_info= {:description => 'io'}
    assert_equal({:description => 'io'}, video.vimeo_info)
    #assert_raise OAuth::Unauthorized do
    #  video.vimeo_info(:remote)
    #end
  end

end
