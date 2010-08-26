module VimeoForEverybody

  module VimeoInstance
    #
    # options = { :account => :user, :players => { :large => {:width=> 200, :height => 100, ...}} 
    def hosted_on_vimeo(options={})
      options.symbolize_keys!
      class_inheritable_accessor :vimeo
      self.vimeo = {}
      self.vimeo[:account] = options[:account] or raise "need an AR model which hold the Viemo account"
      self.vimeo[:players] = {:default =>{}}.update(options[:players] || {})

      serialize :vimeo_info

      include InstanceMethods
      extend ClassMethods
    end

    module InstanceMethods

      def upload(file_path)
        upload_api = send(self.class.vimeo[:account]).vimeo(:upload)
        ticket = upload_api.get_ticket
        upload_api.upload(file_path,ticket.id,ticket.endpoint)
      end



      #url :     The Vimeo URL for a video.
      #width :   (optional) The exact width of the video. Defaults to original size.
      #maxwidth :(optional) Same as width, but video will not exceed original size.
      #height :  (optional) The exact height of the video. Defaults to original size.
      #maxheight:(optional) Same as height, but video will not exceed original size.
      #byline :  (optional) Show the byline on the video. Defaults to true.
      #title :   (optional) Show the title on the video. Defaults to true.
      #portrait :(optional) Show the user's portrait on the video. Defaults to true.
      #color :   (optional) Specify the color of the video controls.
      #callback :(optional) When returning JSON, wrap in this function.
      #autoplay :(optional) Automatically start playback of the video. Defaults to false.
      #xhtml :   (optional) Make the embed code XHTML compliant. Defaults to true.
      #api :     (optional) Enable the Javascript API for Moogaloop. Defaults to false.
      #wmode :   (optional) Add the "wmode" parameter. Can be either transparent or opaque.
      #iframe :  (optional) Use our new embed code. Defaults to true. New!

      def vimeo_player(*args)
        options = args.extract_options!.symbolize_keys!
        player_name = args.first || :default
        options = self.class.vimeo[:players][player_name].dup.update(options)

        oembed = "http://vimeo.com/api/oembed.json?url=http%3A//vimeo.com/" + vimeo_id.to_s
        oembed += "?"+ options.to_param unless options.blank?
        HTTParty.get(oembed)['html']
      end



      #title : Video title
      #url : URL to the Video Page
      #id : Video ID
      #description : The description of the video
      #thumbnail_small : URL to a small version of the thumbnail
      #thumbnail_medium : URL to a medium version of the thumbnail
      #thumbnail_large : URL to a large version of the thumbnail
      #user_name : The user name of the video's uploader
      #user_url : The URL to the user profile
      #upload_date : The date/time the video was uploaded on
      #user_portrait_small : Small user portrait (30px)
      #user_portrait_medium : Medium user portrait (100px)
      #user_portrait_large : Large user portrait (300px)
      #stats_number_of_likes : # of likes
      #stats_number_of_views : # of views
      #stats_number_of_comments : # of comments
      #duration : Duration of the video in seconds
      #width : Standard definition width of the video
      #height : Standard definition height of the video
      #tags : Comma separated list of tags

      def vimeo_info(remote = nil )
        if vimeo_id
          read_attribute(:vimeo_info).blank? or remote.to_s == 'remote' ? Vimeo::Simple::Video.info(vimeo_id).parsed_response.first : read_attribute(:vimeo_info) 
        end
      end
      def set_vimeo_info
        self.vimeo_info = vimeo_info(:remote)
      end

    end

    module ClassMethods
      def init_from_vimeo
        self.vimeo_info = vimeo_info(vimeo_id)
      end
    end
  end

end

ActiveRecord::Base.extend VimeoForEverybody::VimeoInstance