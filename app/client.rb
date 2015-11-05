require 'shat/config'
require 'shat/client/version'
require 'shat/client/connection'

Shat::Config.load

include Shat::Client

puts "Shat Client #{VERSION}"

def get_username(prompt='Select username : ')
  print prompt
  gets.chomp
end

@username = Shat::Config.username || get_username

begin
  conn = Connection.new(@username,
                        Shat::Config.remote_host,
                        Shat::Config.remote_port)
  conn.open
  require 'pry'; binding.pry
rescue Connection::UsernameTaken
  @username = get_username('Please select another username : ')
  retry
ensure
  conn.close
end
