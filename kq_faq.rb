
class KQFAQ < Plugin

  def initialize
    super
    @registry.set_default(Hash.new)
  end

  def help(plugin, topic="")
    "FAQ plugin. Will answer questions on topic in the database. \n"\
    "type '!kqfaq set foo bar baz' to set 'foo' to 'bar baz'"
  end

  def set(m, p)
    h = @registry[m.channel.downcase]
    h[p[:question]] = p[:answer].to_s
    @registry[m.channel.downcase] = h
    m.okay
  end

  def unset(m, p)
    h = @registry[m.channel.downcase]
    h.delete p[:question]
    @registry[m.channel.downcase] = h
    m.okay
  end

  def message(m)
    h = @registry[m.channel.downcase]
    possible_question = m.message.scan(/\w+/).first
    return unless h.has_key? possible_question

    m.reply h[possible_question]
  end

end

plugin = KQFAQ.new

plugin.map 'kqfaq set :question *answer', :action => :set, :auth_path => 'kqfaq'
plugin.map 'kqfaq unset :question', :action => :unset, :auth_path => 'kqfaq'
plugin.default_auth('kqfaq', false)
