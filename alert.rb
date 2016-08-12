
class AlertPlugin < Plugin

  def initialize
    super
    @registry.set_default(Array.new)
  end

  def help(plugin, topic="")
    "Alerts people in two modes: opt-in and opt-out. Three modes are supported: enabled, default, disabled.\n"\
    "type !alert disable/default/disable to explicitly choose. Default: default."
  end

  def setNickMode(chan, nick, mode)
    if mode != :default
      @registry[chan.to_s.downcase].delete nick.to_s.downcase
    else
      @registry[chan.to_s.downcase][nick.to_s.downcase] = mode
    end
  end

  def getNickMode(chan, nick)
    @registry[chan.to_s.downcase].fetch(nick.to_s.downcase, :default)
  end


  # def getIgnoredNicks(chan)
  #   @registry.sub_registry('alertPlugin')['ignoredNicks'].to_a
  # end

  # def addIgnoredNick(nick)
  #   arr = @registry.sub_registry('alertPlugin')['ignoredNicks'].to_a
  #   arr.push nick.downcase
  #   arr.uniq!
  #   @registry.sub_registry('alertPlugin')['ignoredNicks'] = arr
  # end

  # def removeIgnoredNick(nick)
  #   arr = @registry.sub_registry('alertPlugin')['ignoredNicks'].to_a
  #   arr.delete nick.downcase
  #   arr.uniq!
  #   @registry.sub_registry('alertPlugin')['ignoredNicks'] = arr
  # end

  def alert(m, p)
    mode = p[:mode].to_s

    c = @bot.channels.find{|c| c.name.downcase == m.channel.to_s.downcase }

    if c == nil
      return
    end

    users = c.users.map{ |u| u.nick.to_s }.sort_by { |u| u.downcase }

    if mode == 'optin'
      users = users.select{ |u| getNickMode(m.channel, u) == :enabled }
    elsif mode == 'optout'
      users = users.reject{ |u| getNickMode(m.channel, u) == :disabled }
    else
      m.reply 'Invalid mode sleected. Allowed: optin, optout.'
      return
    end

    # c.users.each { |u| users.push u.nick unless ignored.include? u.nick.downcase }


    users.each_slice(15).to_a.each{ |u|
      m.reply "#{u.join(', ')}!"
    }

    m.reply "If you want to change your alert mode, type !help alert"
  end

  def disable(m, p)
    p[:nick] = m.source.nick.to_s.downcase
    disableNick m, p 
    m.okay
  end

  def default(m, p)
    p[:nick] = m.source.nick.to_s.downcase
    defaultNick m, p 
    m.okay
  end

  def enable(m, p)
    p[:nick] = m.source.nick.to_s.downcase
    enableNick m, p
    m.okay
  end

  def disableNick(m, p)
    setNickMode m.channel, p[:nick], :disabled
    m.reply "Done."
  end

  def defaultNick(m, p)
    setNickMode m.channel, p[:nick], :default
    m.reply "Done."
  end

  def enableNick(m, p)
    setNickMode m.channel, p[:nick], :enabled
    m.reply "Done."
  end

end



plugin = AlertPlugin.new

plugin.map 'alert :mode', :private => false, :action => :alert, :auth_path => 'alert', :defaults => { :mode => 'optout' }
plugin.map 'alert disable', :action => :disable
plugin.map 'alert default', :action => :default
plugin.map 'alert enable', :action => :enable
plugin.map 'alert disable :nick', :action => :disableNick, :auth_path => 'alert'
plugin.map 'alert default :nick', :action => :defaultNick, :auth_path => 'alert'
plugin.map 'alert enable :nick', :action => :enableNick, :auth_path => 'alert'
plugin.default_auth('alert', false)
