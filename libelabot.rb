require 'rubygems'
require 'net/irc'
require 'yaml'
require 'open-uri'
require 'kconv'

$KCODE = 'u'

class SimpleClient < Net::IRC::Client
  def initialize(*args)
    super
    @incre_counter = {}
    @decre_counter = {}
  end

  def on_rpl_welcome(m)
    puts '\t\trpl_welcome'
    post JOIN, "#libelabo"
    post JOIN, "#june29"
    post JOIN, "#kei-s"
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

      # URL title fetcher
      if message =~ /((<\w+.*?>|[^=!:'"\/]|^)((?:http[s]?:\/\/)|(?:www\.))([^\s<]+\/?)([[:punct:]]|\s|<|$))/
        url = $1.gsub(' ', '')
        response = open(url)
        doc = response.read
        content_type = response.content_type
        charset = response.charset
        s = ""
        if doc =~ /<title>\s*(.*)\s*<\/title>/i
          s += $1.toutf8 + " "
        end
        s += [content_type, charset].join(',')
        post NOTICE, channel, s
      end

      # Increment and Decrement counter
      if message =~ /([\w\-_]*[\w\_])(\+{2}|\-{2})/
        name = $1
        if $2 == "++"
          unless @incre_counter.member? name
            @incre_counter[name] = 1
          else
            @incre_counter[name] += 1
          end
        elsif $2 == "--"
          unless @decre_counter.member? name
            @decre_counter[name] = 1
          else
            @decre_counter[name] += 1
          end
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
