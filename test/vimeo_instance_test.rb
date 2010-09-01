require 'test_helper'

class VimeoInstanceTest < ActiveSupport::TestCase

  def setup
    @owner = Owner.create(:vimeo_secret => 12, :vimeo_token => 13, :vimeo_api_key =>12, :vimeo_api_secret => 15 )
    @movie = @owner.movies.build(:vimeo_id => 12)
    @movie.vimeo_info_local = {'description' => 'io'}
    @movie.description = 'io'
  end

  def teardown
    unregister_uri
  end

  def test_vimeo_info
    assert_equal({"description" => 'io'}, @movie.vimeo_info)
    register_uri :post, /vimeo/, 'video_advanced_info'
    assert_equal "test", @movie.vimeo_info(:remote)["title"]
  end

  def test_synchronize_local
    register_uri :post, /vimeo/, 'video_advanced_info'
    assert @movie.synchronize(:local)
    assert_equal "test", @movie.vimeo_info["title"]
  end

  #fakeweb can't process request bodies, 
  #so we aren't able to make any difference between Vimeo::Advanced::Video.get_info and Vimeo::Advanced::Video.set_description
  def test_synchronize_remote
    register_uri :post, /vimeo/, 'accept', 'video_advanced_info'
    assert @movie.synchronize(:remote)
  end

  def test_synchronize_callback
    register_uri :post, /vimeo/, 'accept', 'video_advanced_info'
    assert @movie.save(false)
    unregister_uri
    assert @movie.save(false)
  end

  def test_title_setter
    register_uri :post, /vimeo/, 'accept', 'video_advanced_info'
    @movie.title = "nicolas"
    @movie.save
  end


  def test_vimeo_instance_need_vimeo_account_or_raise_exception
    assert_raise VimeoForEverybody::Exception do
      Movie.new.vimeo_api(:video)
    end
  end

  def test_vimeo_thumbnails
    register_uri :post, /vimeo/, 'video_advanced_info'
    @movie.synchronize(:local)
    assert @movie.vimeo_thumbnail(:large).is_a?(Hash)
    assert @movie.vimeo_thumbnail.is_a?(Hash)
    assert_match /ats\.vimeo\.com/, @movie.vimeo_thumbnail_url(:large)
  end

  def test_upload
    register_uri(:post, /vimeo/, 'get_quota', 'get_ticket', 'complete' )
    register_uri(:post, /upload_multi/, {:body => "0", :status => 200})
    @movie.upload(fixture_path + 'sample_iTunes.mov')
    assert_equal "1234567", @movie.vimeo_id 
  end

  def test_player
    register_uri(:get, /vimeo/, 'player' )
    html = @movie.vimeo_player(:id =>"id_test", :class => "class_test")
    assert_match /class=\"class_test\" id=\"id_test\"/, html
  end


end
