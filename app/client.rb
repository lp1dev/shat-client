require 'shat/config'
require 'shat/client/version'
require 'shat/client/connection'

Shat::Config.load

include Shat::Client

puts "Shat Client #{VERSION}"

Connection.new(Shat::Config.remote_host, Shat::Config.remote_port).open do |conn|
  require 'pry'; binding.pry
end
