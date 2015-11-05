require 'json'
require 'socket'
require 'securerandom'
require 'shat/crypto'

module Shat
  module Client
    class Connection
      attr_reader   :socket, :user_list
      attr_accessor :remote_host, :remote_port, :username

      def initialize(username='anonymous', remote_host='127.0.0.1', remote_port=80)
        @remote_host = remote_host
        @remote_port = remote_port
        @username    = username
      end

      def close
        msg = {logout: {}}
        send(msg)
        close_socket
      end

      def open
        open_socket
        handshake
        if block_given?
          yield self
          close
        end
      end

      def private_key
        @__private_key__ ||= SecureRandom.hex(13)
      end

      def receive
        msg = Shat::Crypto.decrypt(@socket.gets, Config.passphrase, Config.iv)
        puts "<=== #{msg}"
        JSON.parse(msg)
      end

      def send(msg)
        msg = msg.merge( {private_key: private_key} ) rescue msg

        crypted = Shat::Crypto.encrypt(msg.to_json, Config.passphrase, Config.iv)
        @socket.puts crypted

        puts "===> #{msg}"
      end

      class UsernameTaken < StandardError; end

      private

      def check_error(resp)
        return if resp['error'].nil?
        raise UsernameTaken if resp['error']['code'] == 4
      end

      def close_socket
        @socket.close if @socket
      end

      def first_step
        msg = {connection: {host: remote_host, login: username}}
        send(msg)
      end

      def get_user_list(resp)
        @user_list = resp.map{ |h| h.select{ |k,_| %w(login ip).include? k }}
      end

      def handshake
        puts 'Authenticating...'

        first_step

        second_step(receive)

        get_user_list(receive)

        puts 'Done.'
      end

      def open_socket
        puts "Connecting to #{remote_host}:#{remote_port}..."
        @socket = TCPSocket.new(remote_host, remote_port)
        puts 'Connected.'
      end

      def second_step(resp)
        check_error(resp)

        key = Shat::Crypto.decrypt(resp['connection']['message'], Config.passphrase, Config.iv)
        msg = {connection: {login: username, message: key}}
        send(msg)
      end
    end
  end
end
