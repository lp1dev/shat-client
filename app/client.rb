require 'shat/config'
require 'shat/client/version'
require 'shat/client/connection'

def invalid_username?(username)
  return true if username.size < 3
  return true if username.size > 13
  return true unless %r(^[\w]*$)u === username
  false
end

def get_username(prompt='Select username : ')
  begin
    print prompt
    username = gets.chomp
    raise if invalid_username?(username)
  rescue
    print 'Username must be between 3 and 13 non-special characters'
    retry
  end
end

def show_user_list(conn)
  puts 'Connected users :'
  puts '-----------------'

  conn.user_list.each do |u|
    puts "#{u['login']}\t|"
  end

  puts '-----------------'
end

###############################################

Shat::Config.load

include Shat::Client

puts "Shat Client #{VERSION}"

@username = Shat::Config.username rescue nil
@username = get_username if @username.nil? || invalid_username?(@username)

begin
  Connection.new(@username,
                 Shat::Config.remote_host,
                 Shat::Config.remote_port).open do |conn|
    show_user_list(conn)
  end
rescue Connection::UsernameTaken
  @username = get_username('Please select another username : ')
  retry
end
