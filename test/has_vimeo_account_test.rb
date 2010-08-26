require 'test_helper'

class HasVimeoAccountTest < ActiveSupport::TestCase

  def setup
    @owner = Owner.new
  end
  def test_vimeo_advanced_api_is_accessible
    assert @owner.vimeo.is_a?(Vimeo::Advanced::Base)
    assert @owner.vimeo(:video).is_a?(Vimeo::Advanced::Video)
    assert_equal @owner.vimeo, @owner.vimeo
    assert_not_equal @owner.vimeo, @owner.vimeo(:force => true)
  end

  def test_synchronize_remote_and_local_collections
    assert_raise OAuth::Unauthorized do
      @owner.videos.synchronize!
    end
  end

  def test_local_collection
    assert_equal [], @owner.videos
  end

  def test_remote_collection
    assert_raise OAuth::Unauthorized do
      @owner.videos(:remote)  
    end
  end

end
