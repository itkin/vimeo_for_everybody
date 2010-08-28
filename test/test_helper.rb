require 'rubygems'




ENV['RAILS_ENV'] = 'test'

require 'ruby-debug'
Debugger.start

if Debugger.respond_to?(:settings)
  Debugger.settings[:autoeval] = true
  Debugger.settings[:autolist] = 1
end

require 'test/unit'
require 'active_support'
require 'fakeweb'


ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..'
require File.expand_path(File.join(ENV['RAILS_ROOT'], 'config/environment.rb'))  

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
db_adapter = ENV['DB']
# no db passed, try one of these fine config-free DBs before bombing.
db_adapter ||=
begin
  require 'rubygems'
  require 'sqlite'
    'sqlite'
rescue MissingSourceFile
  begin
    require 'sqlite3'
      'sqlite3'
  rescue MissingSourceFile
    begin
      require 'mysql'
        'mysql'
    rescue MissingSourceFile
    end
  end
end
if db_adapter.nil?
  raise "No DB Adapter selected. Pass the DB= option to pick one, or install Sqlite or Sqlite3."
end

#FakeWeb.allow_net_connect = false

require File.dirname(__FILE__) + '/../init'
ActiveRecord::Base.establish_connection(config[db_adapter])
#load(File.dirname(__FILE__) + "/schema.rb")
load(File.dirname(__FILE__) + "/model.rb")

def fixture_file(file_name)
  File.read( File.expand_path(File.dirname(__FILE__)) + '/responses/' + file_name + '.json' ) 
end

def register_uri(method, uri, filename)
  FakeWeb.register_uri(method, uri, :body => fixture_file(filename), :content_type => 'application/json')
end

def unregister_uri
  FakeWeb.clean_registry
end


