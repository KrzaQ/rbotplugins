
class AlertPlugin < Plugin

  def initialize
    super
    @registry.set_default(Hash.new)
  end

  def help(plugin, topic="")
    "Alerts people. Three user modes are supported: enabled (all alerts), default (default), disabled (no alerts).\n"\
    "Type !alert enable/default/disable to explicitly choose. Default: default."
  end

  def setNickMode(chan, nick, mode)
    all = @registry[chan.to_s.downcase]
    if mode == :default
      all.delete nick.to_s.downcase
    else
      all[nick.to_s.downcase] = mode
    end
      @registry[chan.to_s.downcase] = all
  end

  def getNickMode(chan, nick)
    @registry[chan.to_s.downcase].fetch(nick.to_s.downcase, :default)
  end

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
      m.reply 'Invalid mode selected. Allowed: optin, optout.'
      return
    end

    users.each_slice(15).to_a.each{ |u|
      m.reply "#{u.join(', ')}!"
    }

    m.reply "If you want to change your alert mode, type !help alert"
  end

  def disable(m, p)
    p[:nick] = m.source.nick.to_s.downcase
    disableNick m, p
  end

  def default(m, p)
    p[:nick] = m.source.nick.to_s.downcase
    defaultNick m, p
  end

  def enable(m, p)
    p[:nick] = m.source.nick.to_s.downcase
    enableNick m, p
  end

  def disableNick(m, p)
    setNickMode m.channel, p[:nick], :disabled
    m.okay
  end

  def defaultNick(m, p)
    setNickMode m.channel, p[:nick], :default
    m.okay
  end

  def enableNick(m, p)
    setNickMode m.channel, p[:nick], :enabled
    m.okay
  end

end

plugin = AlertPlugin.new

plugin.map 'alert disable', :action => :disable
plugin.map 'alert default', :action => :default
plugin.map 'alert enable', :action => :enable
plugin.map 'alert disable :nick', :action => :disableNick, :auth_path => 'alert'
plugin.map 'alert default :nick', :action => :defaultNick, :auth_path => 'alert'
plugin.map 'alert enable :nick', :action => :enableNick, :auth_path => 'alert'
plugin.map 'alert :mode', :private => false, :action => :alert, :auth_path => 'alert', :defaults => { :mode => 'optout' }
plugin.default_auth('alert', false)
