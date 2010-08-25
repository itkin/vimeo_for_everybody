module VimeoForEverybody

  module HasVimeoAccount

    def has_vimeo_account
      #attr_accessor_with_default :vimeo, {}
      include InstanceMethods
    end

    module InstanceMethods

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

      def vimeo_instances(options={})
        vimeo(:video).get_all(vimeo_id, options={})
      end

    end

  end

end

ActiveRecord::Base.extend VimeoForEverybody::HasVimeoAccount