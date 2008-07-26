require 'rubygems'
require 'net/irc'
require 'yaml'
require 'open-uri'

require 'pp'

class SimpleClient < Net::IRC::Client
  @@counter = {}
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

    if channel =~ /^#/
      if message =~ /Hello/
        post PRIVMSG, channel, "Hello!"
      end

      if message =~ /(.*)\+\+/
        name = $1
        unless @@counter.member? name
          @@counter[name] = 0
        end

        @@counter[name] += 1

        post NOTICE, channel, "(#{name} : #{@@counter[name]})"
      end
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
