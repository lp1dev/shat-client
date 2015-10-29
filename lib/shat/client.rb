require 'shat/config'
require 'shat/client/version'
require 'shat/client/connection'

Shat::Config.load

module Shat
  module Client
    include Shat::Config

    puts "Shat Server #{VERSION}"

    conn = Connection.new(Config.remote_host, Config.remote_port)
    conn.open
  end
end

exit
