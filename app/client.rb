require 'shat/config'
require 'shat/client/version'
require 'shat/client/connection'

Shat::Config.load

include Shat::Config
include Shat::Client

puts "Shat Server #{VERSION}"

conn = Connection.new(Shat::Config.remote_host, Shat::Config.remote_port)
conn.open
