
class AlertPlugin < Plugin

  def initialize
    super
    @registry.set_default(Array.new)
  end

  def help(plugin, topic="")
    "Alerts everyone, lol. To disable alerting your nick, type !alert disable. To enable it again"\
    "type !alert enable"
  end

  def getIgnoredNicks
    @registry.sub_registry('alertPlugin')['ignoredNicks'].to_a
  end

  def addIgnoredNick(nick)
    arr = @registry.sub_registry('alertPlugin')['ignoredNicks'].to_a
    arr.push nick.downcase
    arr.uniq!
    @registry.sub_registry('alertPlugin')['ignoredNicks'] = arr
  end

  def removeIgnoredNick(nick)
    arr = @registry.sub_registry('alertPlugin')['ignoredNicks'].to_a
    arr.delete nick.downcase
    arr.uniq!
    @registry.sub_registry('alertPlugin')['ignoredNicks'] = arr
  end

  def alert(m, p)
  	c = @bot.channels.find{|c| c.name.downcase == m.channel.to_s.downcase }

  	if c == nil
  		return
  	end

  	users = []

    ignored = getIgnoredNicks

  	c.users.each { |u| users.push u.nick unless ignored.include? u.nick.downcase }


    users = users.sort_by { |u| u.downcase }

    users.each_slice(15).to_a.each{ |u|
      m.reply "#{u.join(', ')}!"
    }

    m.reply "If you do not want to be alerted by me, please type !alert disable"
  end

  def disable(m, p)
    addIgnoredNick m.source.nick.to_s.downcase
    m.reply "Done."
  end

  def enable(m, p)
    removeIgnoredNick m.source.nick.to_s.downcase
    m.reply "Done."
  end

end



plugin = AlertPlugin.new

plugin.map 'alert', :private => false, :action => :alert, :auth_path => 'alert'
plugin.map 'alert disable', :action => :disable
plugin.map 'alert enable', :action => :enable
plugin.default_auth('alert', false)