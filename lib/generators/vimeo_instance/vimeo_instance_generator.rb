
class VimeoInstanceGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def manifest
    template "add_vimeo_fields_to_vimeo_instance_class", "db/migrate/#{DateTime.now.strftime("%Y%m%d%H%M%S")}_add_vimeo_fields_to_#{plural_name}"
  end

end
