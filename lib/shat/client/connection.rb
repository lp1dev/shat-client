require 'json'
require 'socket'
require 'shat/crypto'

module Shat
  module Client
    class Connection
      attr_reader   :socket
      attr_accessor :remote_host, :remote_port

      def initialize(remote_host='127.0.0.1', remote_port=80)
        @remote_host = remote_host
        @remote_port = remote_port
      end

      def close
        close_socket
      end

      def open
        open_socket
        handshake
      end

      def send(msg)
        @socket.puts Shat::Crypto.encrypt(msg, Config.passphrase, Config.iv)
      end

      private

      def handshake
        puts 'Authenticating...'
        msg = {hello: remote_host}.to_json
        send(msg)
        puts 'Done.'
      end

      def close_socket
        @socket.close
      end

      def open_socket
        puts "Connecting to #{remote_host}:#{remote_port}..."
        @socket = TCPSocket.new(remote_host, remote_port)
        puts 'Connected.'
      end
    end
  end
end
