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
    register_uri :post, /vimeo/, 'video_advanced_info'
    assert_equal "test", @movie.vimeo_info(:remote)["title"]
  end

  def test_set_vimeo_info_update_vimeo_info_local_with_remote_values
    register_uri :post, /vimeo/, 'video_advanced_info'
    assert @movie.set_vimeo_info
    assert_equal "test", @movie.vimeo_info["title"]
  end

  #fakeweb can't process request bodies, 
  #so we aren't able to make any difference between Vimeo::Advanced::Video.get_info and Vimeo::Advanced::Video.set_description
  def test_set_vimeo_info_update_update_remote_info_with_passed_attributes
    register_uri :post, /vimeo/, 'video_advanced_info'
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

  def test_vimeo_thmbnails
    register_uri :post, /vimeo/, 'video_advanced_info'
    @movie.set_vimeo_info
    assert @movie.vimeo_thumbnail(:large).is_a?(Hash)
    assert @movie.vimeo_thumbnail.is_a?(Hash)
    assert_match /ats\.vimeo\.com/, @movie.vimeo_thumbnail_url(:large)
  end

end
