require 'test_helper'

class HasVimeoAccountTest < ActiveSupport::TestCase

  def test_init
    owner = Owner.new
    assert owner.vimeo.is_a?(Vimeo::Advanced::Base)
    assert owner.vimeo(:video).is_a?(Vimeo::Advanced::Video)
    assert_equal owner.vimeo, owner.vimeo
    assert_not_equal owner.vimeo, owner.vimeo(:force => true)
  end
    
end
