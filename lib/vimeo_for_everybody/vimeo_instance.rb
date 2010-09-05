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
      self.vimeo[:shared_attributes] = options[:shared_attributes] || [:title, :description]

      serialize :vimeo_info_local
      attr_accessor_with_default :vimeo_is_synch, false
      
      before_save { |instance|
        instance.synchronize
      }

      after_destroy { |instance|
        instance.vimeo_api(:video).delete(instance.vimeo_id)
      }

      include InstanceMethods
      
    end
    module InstanceMethods

      def synchronize(target = :remote)
        if not vimeo_is_synch and vimeo_id
          self.vimeo_is_synch = true
          if target.to_s == 'remote'
            vimeo[:shared_attributes].each do |attr|
              vimeo_api(:video).send("set_#{attr}", send(attr),vimeo_id) if changed.include?(attr.to_s)
            end
            self.vimeo_info_local = vimeo_info(:remote)
          elsif target.to_s == 'local'
            self.vimeo_info_local = vimeo_info(:remote)
            vimeo[:shared_attributes].each do |attr|
              self.send("#{attr}=", vimeo_info[attr.to_s])
            end
          end
        end
      end

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
        quota = upload_api.get_quota["user"]["upload_space"]["free"]
        if quota.to_i < File.size(file_path)
          raise "No more space available (#{quota["upload_space"]["free"]} B remains, whereas file size is #{File.size(file_path)} B )"
        end

        #get an upload ticket
        ticket = upload_api.get_ticket["ticket"]

        #upload the file

        upload_api.upload(ticket["endpoint"], file_path, ticket["id"])

        # complete the upload
        rsp = upload_api.complete(ticket["id"], File.basename(file_path))
        
        #store the video_id locally
        self.vimeo_id= rsp["ticket"]["video_id"]
        Kernel::sleep 2
        self.synchronize(:local)
        self.save
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
      #id   : added to the iframe
      #class: added to the iframe
      def vimeo_player(*args)
        options = args.extract_options!.symbolize_keys!
        html_options = {:id => options.delete(:id)}.update(:class=> options.delete(:class)).delete_if{|k,v| v.nil?}
        player_name = args.first || :default
        options = self.class.vimeo[:players][player_name].dup.update(options)

        oembed = "http://vimeo.com/api/oembed.json?url=http%3A//vimeo.com/" + vimeo_id.to_s
        oembed += "?"+ options.to_param unless options.blank?

        HTTParty.get(oembed)['html'].gsub('<iframe',"<iframe #{html_options.collect{|opt| "#{opt[0]}=\"#{opt[1]}\" "}}")
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
        (vimeo_id and remote.to_s == 'remote') ? vimeo_api(:video).get_info(vimeo_id)["video"].first : vimeo_info_local || {}
      end

      #format = small, medium, large
      def vimeo_thumbnail(format='small')
        thumbnail_id = case format.to_s
          when 'small' then 0
          when 'medium' then 1
          when 'large' then 2
          else 0
        end
        vimeo_info["thumbnails"]["thumbnail"][thumbnail_id]
      end
      
      def vimeo_thumbnail_url(format='small')
        vimeo_thumbnail(format='small')["_content"]
      end


      
    end
  end

end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.extend VimeoForEverybody::VimeoInstance
end