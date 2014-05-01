require 'uri'
require 'json'
require 'net/http'
require 'httpclient'
require 'xmlsimple'

class TranslatePlugin < Plugin

  def initialize
    super
    @registry.set_default(Array.new)
    @token = {
      :expires => Time.at(0).to_i,
      :string => nil
    }

    conf = @bot.config['translate']

    @client_id = conf['client_id']
    @app_secret = conf['app_secret']
    @default_language = conf['default_language']

  end

  def help(plugin, topic="")
    'Translation plugin utilising bing translate. !tr <text> to translate ' +
    '<text> to the default language or !trex <from> <to> <text> ' +
    'to translate <text> from <from> to <to>'
  end

  def checkOrGetToken()
    if(@token[:expires] < Time.new.to_i or @token[:string] == nil)
       
      http = HTTPClient.new(:agent_name => 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20100101 Firefox/25.0')
      
      post = {
          :client_id => URI::encode(@client_id),
          :client_secret => URI::encode(@app_secret),
          :scope => 'http://api.microsofttranslator.com',
          :grant_type => 'client_credentials'
      }

      r = http.post('https://datamarket.accesscontrol.windows.net/v2/OAuth2-13',post)

      link = nil
      
      parsed = nil

      begin
        parsed = JSON.parse(r.body)
      rescue Exception => e
        raise r.body
      end

      @token[:string] = parsed['access_token']
      @token[:expires] = parsed['expires_in'].to_i + Time.new.to_i - 60

      link = parsed['id'] if parsed != nil

      return link
    end
  end

  def httpRequest(url,params)
    checkOrGetToken
    http = HTTPClient.new(:agent_name => 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20100101 Firefox/25.0')
    hdr = { 'Authorization' => "Bearer " + @token[:string] }
    # url = "http://api.microsofttranslator.com/v2/Http.svc/Detect?"

    params.each { |k,v|
      url += "#{k}=#{URI::encode v}&"
    }

    r = http.get(url,'',hdr)
    raise r.body if r.status != 200
    return r
  end

  def detectLanguage(text)

    r = httpRequest("http://api.microsofttranslator.com/v2/Http.svc/Detect?",{ :text => text })

    res = XmlSimple.xml_in(r.body)

    return res['content']

  end

  def translate(from,to,text)
    param = {
      :from => from,
      :to => to,
      :text => text
    }

    r = httpRequest("http://api.microsofttranslator.com/v2/Http.svc/Translate?",param)

    res = XmlSimple.xml_in(r.body)

    return res['content']
  end

  def getTokenStr()
    # "Token: #{@token[:string]}. Expires in #{Time.new.to_i - @token[:expires]} seconds"
    @token.inspect.to_s
  end

  # def trtoken(m,params)
  #   begin
  #     m.reply "Token: #{getTokenStr()}"
          
  #     checkOrGetToken

  #     m.reply "Token: #{getTokenStr()}"
  #   rescue Exception => e
  #     m.reply "Exception: #{e.message}"
  #     e.backtrace.each { |l|
  #       # m.reply "Backtrace: #{l}"
  #     }
  #   end

  # end

  # def trdetect(m, params)
  #   begin
  #     checkOrGetToken
  #     text = params[:params].to_a.join(' ')

  #     result = detectLanguage text

  #     m.reply "Detected language: #{result}"

  #   rescue Exception => e
  #     m.reply "Exception: #{e.message}"
  #     e.backtrace.each { |l|
  #       # m.reply "Backtrace: #{l}"
  #     }
  #   end

  # end

  def do_translate(m, params)
    text = params[:q].to_a.join(' ')
    Thread.new do
      begin

        lang = detectLanguage text

        m.reply "Translating from detected language: #{Bold}#{lang.upcase}#{Bold}"
        str = translate(lang,@default_language,text)

        m.reply "#{Color}#{Irc.color(:green)}#{str}#{Color}"
      rescue Exception => e
        m.reply "Exception: #{e.message}. Message: #{text}"
        e.backtrace.each { |l|
          puts "Backtrace: #{l}"
        }
      end
    end
  end

  def do_translateex(m, params)
    from = params[:from]
    to = params[:to]
    text = params[:q].to_a.join(' ')
    Thread.new do
      begin

        m.reply "Translating from: #{Bold}#{from.upcase}#{Bold} to #{Bold}#{to.upcase}#{Bold}"
        str = translate(from,to,text)

        m.reply "#{Color}#{Irc.color(:green)}#{str}#{Color}"
      rescue Exception => e
        m.reply "Exception: #{e.message}. Message: #{text}"
        e.backtrace.each { |l|
          puts "Backtrace: #{l}"
        }
      end
    end
  end

end


plugin = TranslatePlugin.new


plugin.map 'tr *q', :action => 'do_translate'
plugin.map 'trex :from :to *q', :action => 'do_translateex'