require 'test_helper'

class HasVimeoAccountTest < ActiveSupport::TestCase

  def setup
    @owner = Owner.new(:vimeo_secret => 12, :vimeo_token => 13, :vimeo_api_key =>12, :vimeo_api_secret => 15 )
  end
  def teardown
    unregister_uri
  end


  def test_vimeo_advanced_api_is_accessible
    assert @owner.vimeo.is_a?(Vimeo::Advanced::Base)
    assert @owner.vimeo(:video).is_a?(Vimeo::Advanced::Video)
    assert_equal @owner.vimeo, @owner.vimeo
    assert_not_equal @owner.vimeo, @owner.vimeo(:force => true)
  end

  #fakeweb can't process request bodies,
  #so we aren't able to make any difference between Vimeo::Advanced::Video.get_uploaded and Vimeo::Advanced::Video.get_info
  def test_synchronize_remote_and_local_collections
    @owner.save

    register_uri :post, /oauth_nonce/, 'videos'
    register_uri  :post, /vimeo/, 'video_advanced_info'

    assert @owner.movies.synchronize!
    assert_equal 1, @owner.movies.size
    assert_equal 'test', @owner.movies.first.vimeo_info['title'] 
  end

  def test_local_collection
    assert_equal [], @owner.movies
  end

  def test_remote_collection
    register_uri  :post, /oauth_nonce/, 'videos'
    vimeo_instances= @owner.movies(:remote)
    assert_equal 1, vimeo_instances.size
  end

end
