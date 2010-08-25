module VimeoForEverybody

  module VimeoInstance

    def has_vimeo_instance(options={})
      class_inheritable_accessor :vimeo_account_belongs_to
      self.vimeo_account_belongs_to = options.delete(:account_belongs_to)
      include InstanceMethods
    end

    module InstanceMethods
      def upload(file_path)
        vimeo = send(self.class.vimeo_account_belongs_to).vimeo(:upload)
        ticket = vimeo.get_ticket
        vimeo.upload(file_path,ticket.id,ticket.endpoint)
      end
      def player(options={})
        oembed = "http://vimeo.com/api/oembed.json?url=http%3A//vimeo.com/" + video_id.to_s
        HTTParty.get(oembed)['html']
      end
    end
  end

end

ActiveRecord::Base.extend VimeoForEverybody::VimeoInstance