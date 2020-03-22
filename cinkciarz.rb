require 'httpclient'
require 'json'
require 'optparse'

class MinApi
    
    def initialize key
        @key = key
    end

    def convert from, to
        params = {
            fsym: from,
            tsyms: to,
            api_key: @key,
            extraParams: 'kq-rbot',
        }
        url = 'https://min-api.cryptocompare.com/data/price?' + params.map do |k, v|
            "#{k}=#{v}"
        end.join('&')
        c = HTTPClient.new
        
        r = c.get url
        
        val = JSON.parse r.body
        raise val["Message"] unless r.code == 200
        val[to]
    end

end

class Cinkciarz < Plugin
    attr_accessor :min_api

    def initialize
        super
        conf = @bot.config['cinkciarz']
        self.min_api = MinApi.new conf['min_api_key']
    end

    def help(plugin, topic="")
        "Currency conversion plugin"
    end

    def message(m)
    end

    def command(m, params)
        begin
            argv = parse params[:command]
            ret = convert argv
            m.reply colourize ret, argv
        rescue => e
            m.reply "Failed: #{e.message}"
        end
    end

    def colourize val, argv
        if argv[:color]
            str = val
            "#{Bold}#{Irc.color(:green)}#{str} #{argv[:to]}#{Irc.color}#{Bold}"
        else
            val
        end
    end

    def convert argv
        val = @min_api.convert argv[:from], argv[:to]
        (val * argv[:amount]).round(4)
    end

    def parse argv
        ret = {
            from: nil,
            to: 'USD',
            color: true,
            amount: 1,
        }
        op = OptionParser.new do |o|
            o.on('--[no-]color'){ |v| ret[:color] = v }
            o.on('--amount AMT'){ |v| ret[:amount] = v.to_f }
        end
        rest = op.parse argv
        raise help_msg unless [1, 2].include? rest.size
        ret[:from] = argv[0].upcase || ret[:from]
        ret[:to] = (argv[1] || ret[:to]).upcase
        ret
    end

    def help_msg
        "Usage: FROM [TO] --[no-]color, --amount AMT"
    end

end

plugin = Cinkciarz.new
plugin.map 'c *command', :action => :command
