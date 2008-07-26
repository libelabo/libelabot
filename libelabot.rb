require 'rubygems'
require 'net/irc'
require 'yaml'

require 'pp'

class SimpleClient < Net::IRC::Client
  def initialize(*args)
    super
  end

  def on_rpl_welcome(m)
    puts '\t\trpl_welcome'
    post JOIN, "#libelabo"
  end

  def on_connected
    puts '\t\tconnected'
  end

  def on_message(m)
    super
    channel, message = *m
    if message =~ /Hello/
      post NOTICE, "#libelabo", "Hello!"
    end
  end
end

account = YAML::load(open('libelabo.yaml'))

@client = SimpleClient.new("irc.freenode.net", "6667", {
                   :nick => "libelabo",
                   :user => "libelabo",
                   :real => "libelabo",
                   :pass => account['irc'],
                 })
@client.start
