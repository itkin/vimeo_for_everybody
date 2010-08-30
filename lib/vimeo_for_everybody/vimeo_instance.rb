module VimeoForEverybody

  class Exception < StandardError; end

  module VimeoInstance
    #
    # options = { :account => :user, :players => { :large => {:width=> 200, :height => 100, ...}} 
    def hosted_on_vimeo(options={})
      options.symbolize_keys!
      class_inheritable_accessor :vimeo
      self.vimeo = {}
      self.vimeo[:account] = options[:account] or raise "need an AR model which hold the Viemo account"
      self.vimeo[:players] = {:default =>{}}.update(options[:players] || {})

      serialize :vimeo_info_local

      attr_accessor :title, :description
      [:title, :description].each do |attr|
        define_method attr do
          vimeo_info[attr]
        end
      end
      
      include InstanceMethods

    end

    module InstanceMethods

      def vimeo_api(api_name)
        unless send(self.class.vimeo[:account]).blank?
          send(self.class.vimeo[:account]).vimeo(api_name)
        else
          raise Exception, "advanced API impossible to reach because lack of vimeo account instance"
        end  
      end
      
      def upload(file_path)
        upload_api = vimeo_api(:upload)

        #check quota
        quota = upload_api.get_quota
        if quota["upload_space"]["free"].to_i < File.size(file_path)
          raise "No more space available (#{quota["upload_space"]["free"]} B remains, whereas file size is #{File.size(file_path)} B )"
        end

        #get an upload ticket
        ticket = upload_api.get_ticket["ticket"]

        #upload the file
        upload_api.upload(ticket["endpoint"], file_path, ticket["id"])

        # complete the upload
        rsp = upload_api.complete(ticket["id"], File.basename(file_path))

        #store the video_id locally
        update_attribute(:video_id, rsp["ticket"]["video_id"])
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

      def vimeo_info(remote=nil)
        (vimeo_info_local.nil? or remote.to_s == 'remote') ? Vimeo::Simple::Video.info(vimeo_id).parsed_response.first : vimeo_info_local
      end

      def set_vimeo_info(attributes={})
        unless attributes.blank?
          vimeo_api(:video).set_title(attributes[:title],vimeo_id) if attributes[:title]
          vimeo_api(:video).set_description(attributes[:description],vimeo_id) if attributes[:description]
        end
        self.vimeo_info_local = vimeo_info(:remote)
      end
    end
  end

end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.extend VimeoForEverybody::VimeoInstance
end