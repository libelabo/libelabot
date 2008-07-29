require 'rubygems'
require 'net/irc'
require 'yaml'
require 'open-uri'

require 'pp'

class SimpleClient < Net::IRC::Client
  def initialize(*args)
    super
    @incre_counter = {}
    @decre_counter = {}
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

      if message =~ /((<\w+.*?>|[^=!:'"\/]|^)((?:http[s]?:\/\/)|(?:www\.))([^\s<]+\/?)([[:punct:]]|\s|<|$))/
        url = $1.gsub(' ', '')
        response = open(url)
        doc = response.read
        content_type = response.content_type
        charset = response.charset
        if doc =~ /<title>[\s\t\n]*(.*)[\s\t\n]*<\/title>/
          title = $1
          post NOTICE, channel, "#{title} [#{content_type},#{charset}]"
        end
      end

      if message =~ /(.*)([+|\-]{2})/
        name = $1
        unless @incre_counter.member? name
          @incre_counter[name] = 0
        end
        unless @decre_counter.member? name
          @decre_counter[name] = 0
        end

        if $2 == "++"
          @incre_counter[name] += 1
        elsif $2 == "--"
          @decre_counter[name] += 1
        end

        incre = @incre_counter[name].to_i
        decre = @decre_counter[name].to_i
        value = incre - decre
        post NOTICE, channel, "#{name} : #{value}  (#{incre}++ #{decre}--)"
      end
    end
  end
end

account = YAML::load(open('libelabo.yaml'))

client = SimpleClient.new("irc.freenode.net", "6667", {
                   :nick => "libelabo",
                   :user => "libelabo",
                   :real => "libelabo",
                   :pass => account['irc'],
                 })
client.start
