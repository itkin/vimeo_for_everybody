require 'test_helper'

class VimeoInstanceTest < ActiveSupport::TestCase

  def setup
    @owner = Owner.create(:vimeo_secret => 12, :vimeo_token => 13, :vimeo_api_key =>12, :vimeo_api_secret => 15 )
    @movie = @owner.movies.build(:vimeo_id => 12)
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

  def test_set_vimeo_info_update_vimeo_info_local_with_remote_values
    register_uri :get, /vimeo/, 'video_info'
    assert @movie.set_vimeo_info
    assert_equal "test", @movie.vimeo_info["title"]
  end
  def test_set_vimeo_info_update_update_remote_info_with_passed_attributes
    register_uri :get, /vimeo/, 'video_info'
    register_uri :post, /vimeo/, 'accept'
    assert @movie.set_vimeo_info(:description => "nicolas")
  end
  def test_description_getter
    assert_equal 'io', @movie.description
  end
  def test_vimeo_instance_need_vimeo_account_or_raise_exception
    assert_raise VimeoForEverybody::Exception do
      Movie.new.vimeo_api(:video)
    end
  end

end
