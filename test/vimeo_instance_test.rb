require 'test_helper'

class VimeoInstanceTest < ActiveSupport::TestCase

  def setup
    @movie = Movie.new(:vimeo_id => 12)
    @movie.vimeo_info_local = {:description => 'io'}
  end
  def teardown
    unregister_uri
  end

  def test_vimeo_info
    assert_equal({:description => 'io'}, @movie.vimeo_info)
    register_uri :get, /vimeo/, 'video_info'
    assert_equal "test", @movie.vimeo_info(:remote)["title"]
  end

  def test_set_vimeo_info
    register_uri :get, /vimeo/, 'video_info'
    assert @movie.set_vimeo_info
    assert_equal "test", @movie.vimeo_info["title"]
  end

end
