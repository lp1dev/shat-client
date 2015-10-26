require 'shat/config'
require 'shat/client/version'

Shat::Config.load

module Shat
  module Client
    include Shat::Config
  end
end
