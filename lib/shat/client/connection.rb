require 'json'
require 'socket'

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

  def connect
    open_socket
    handshake
  end

  private

  def handshake
    socket.puts({hello: remote_host}.to_json)
  end

  def close_socket
    socket.close
  end

  def open_socket
    socket = TCPSocket.new(remote_host, remote_port)
  end
end
