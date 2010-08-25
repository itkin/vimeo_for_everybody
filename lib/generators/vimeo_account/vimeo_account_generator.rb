require 'rails/generators/base'
require 'rails/generators/named_base'

class VimeoAccountGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def manifest
    template "add_vimeo_fields_to_vimeo_account_class.erb", "db/migrate/#{DateTime.now.strftime("%Y%m%d%H%M%S")}_add_vimeo_fields_to_#{plural_name}.rb"
  end

end
