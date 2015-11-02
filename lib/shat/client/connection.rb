require 'json'
require 'socket'
require 'securerandom'
require 'shat/crypto'

module Shat
  module Client
    class Connection
      attr_reader   :socket, :user_list, :username
      attr_accessor :remote_host, :remote_port

      def initialize(remote_host='127.0.0.1', remote_port=80)
        @remote_host = remote_host
        @remote_port = remote_port
        @username    = Config.username rescue 'anonymous'
      end

      def close
        msg = {logout: {login: username}}
        send(msg)
        close_socket
      end

      def receive
        msg = Shat::Crypto.decrypt(@socket.gets, Config.passphrase, Config.iv)
        puts "<=== #{msg}"
        msg
      end

      def open
        open_socket
        handshake
        show_user_list
        if block_given?
          yield self
          close
        end
      end

      def private_key
        @__private_key__ ||= SecureRandom.hex(13)
      end

      def send(msg)
        msg = msg.merge( {private_key: private_key} ) rescue msg

        crypted = Shat::Crypto.encrypt(msg.to_json, Config.passphrase, Config.iv)
        @socket.puts crypted

        puts "===> #{msg}"
      end

      private

      def close_socket
        @socket.close if @socket
      end

      def first_step
        msg = {hello: remote_host}
        send(msg)
      end

      def get_user_list(response)
        @user_list = JSON.parse(response).map{ |h| h.select{ |k,_| %w(login ip).include? k }}
      end

      def handshake
        puts 'Authenticating...'

        first_step
        resp = JSON.parse(receive)

        second_step(resp)

        get_user_list(receive)

        puts 'Done.'
      end

      def open_socket
        puts "Connecting to #{remote_host}:#{remote_port}..."
        @socket = TCPSocket.new(remote_host, remote_port)
        puts 'Connected.'
      end

      def second_step(resp)
        key = Shat::Crypto.decrypt(resp['message'], Config.passphrase, Config.iv)
        msg = {connection: {login: username, message: key}}
        send(msg)
      end

      def show_user_list
        puts "Connected users :\n"
        @user_list.each do |u|
          puts "#{u['login']}, #{u['ip']}"
        end
      end
    end
  end
end
