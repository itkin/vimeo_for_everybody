require 'test_helper'

class VimeoInstanceTest < ActiveSupport::TestCase

  def setup
    @video = Video.new(:vimeo_id => 12)
    @video.vimeo_info = {:description => 'io'}
  end
  def test_vimeo_info
    assert_equal({:description => 'io'}, @video.vimeo_info)
    fake_request :get, 'http://vimeo', 'video_info' do
      assert_equal "my home (minn heima)", @video.vimeo_info(:remote)["title"]
    end
  end

  def test_set_vimeo_info
    fake_request :get, 'http://vimeo', 'video_info' do
      assert @video.set_vimeo_info
      assert_equal "my home (minn heima)", @video.vimeo_info["title"]
    end
  end

end
