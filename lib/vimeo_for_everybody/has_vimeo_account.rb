module VimeoForEverybody

  module VimeoAccount

    def self.extended(base)
      base.class_eval do
        class << self
          alias_method_chain :has_many, :vimeo_option
        end
      end
    end

    def has_many_with_vimeo_option(association_id, options = {}, &extension)
      if options.symbolize_keys!.delete(:hosted_on).to_s == 'vimeo'
        options[:extend] = [options[:extend]].flatten.compact << VimeoSynchExtention
        has_many_without_vimeo_option(association_id, options, &extension)             


        # Add a :remote param to access to the collection of vimeo instances
        #
        # Ex : user.videos(:remote) => [{'id'=>12345, 'title' => 'test', 'description'=>'test', 'duration'=>200, ..}]
        #
        # Same behavior as AR, passing arguments true, :remote reset the cached remote collection
        #
        define_method "#{association_id}_with_remote" do |*args|
          options = args.extract_options!.symbolize_keys!
          if args.last.to_s == 'remote'
            @vimeo_instances = nil if args.first == true
            @vimeo_instances ||= vimeo(:video).get_all(vimeo_id, options={})["videos"]["video"]
          else
            send "#{association_id}_without_remote", *args
          end
        end

        alias_method_chain association_id, :remote


        # Add a :remote param to access the vimeo_ids of the instances remotely stored
        #
        # Ex : user.video_ids(:remote) => [1234,5678,89012]
        #
        define_method "#{association_id.to_s.singularize}_ids_with_remote" do |*args|
          if args.blank?
            send "#{association_id.to_s.singularize}_ids_without_remote"
          else
            send(association_id, *args).collect{|vimeo_instance| vimeo_instance['id']}
          end
        end

        alias_method_chain "#{association_id.to_s.singularize}_ids", :remote 

        include VimeoAdvancedApiAccess
      else
        has_many_without_vimeo_option(association_id, options, &extension)
      end
    end

    module VimeoSynchExtention
      def synchronize!
        destroy_local_instances_without_remote_ones do
          proxy_owner.send("#{proxy_reflection.name.to_s.singularize}_ids", true, :remote).collect do |vimeo_id|
            local_instance = proxy_reflection.klass.init_from_vimeo(vimeo_id)
            local_instance.user_id = id
            local_instance.save
            local_instance
          end
        end
        proxy_owner.send proxy_reflection.name, true
      end

      def destroy_local_instances_without_remote_ones(&user_videos_on_vimeo)
        (proxy_target - user_videos_on_vimeo.call).map(&:destroy)
      end
    end

    module VimeoAdvancedApiAccess

      #instanciate and store a Vimeo::Advanced::KlassName API object (Base per default)
      def vimeo(*params)
        options = params.extract_options!.symbolize_keys!
        klass_name = params.first || :base
        @vimeo ||= {}
        @vimeo[klass_name.to_sym] = nil if options.delete(:force)
        @vimeo[klass_name.to_sym] ||= "Vimeo::Advanced::#{klass_name.to_s.classify}".constantize.new(vimeo_api_key, vimeo_api_secret, :token => options[:token] || vimeo_token, :secret => options[:secret] || vimeo_secret)
      end

      def rescue_vimeo_request(&block)
        begin
          yield
        rescue Vimeo::Advanced::RequestFailed => e
          self.errors.add(:vimeo, e.message)
          false
        rescue Exception
          false
        end
      end

      def vimeo_set_access(oauth_token, oauth_secret, oauth_verifier)
        rescue_vimeo_request do
          access_token = vimeo.get_access_token(oauth_token, oauth_secret, oauth_verifier)
          self.vimeo_token = access_token.token
          self.vimeo_secret = access_token.secret
          self.vimeo_id = vimeo(:force => true).check_access_token["oauth"]["user"]["id"]
          save
        end
      end

      def vimeo_check_access
        rescue_vimeo_request do
          vimeo.check_access_token
        end          
      end

    end



  end

end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.extend VimeoForEverybody::VimeoAccount
end  