
class KQFAQ < Plugin

  def initialize
    super
    @registry.set_default(Hash.new)
  end

  def help(plugin, topic="")
    "FAQ plugin. Will answer questions on topic in the database. \n"\
    "type '!faq set foo bar baz' to set 'foo' to 'bar baz'"
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

  def list(m, p)
    h = @registry[m.channel.downcase]
    m.reply h.keys.sort.join(", ")
  end

  def get(m, p)
    h = @registry[m.channel.downcase]
    if h.has_key? p[:question]
      m.reply h[p[:question]]
    else
      m.reply 'unknown question: %s' % p[:question]
    end
  end

  # def message(m)
  #   h = @registry[m.channel.downcase]
  #   possible_question = m.message.scan(/\w+/).first
  #   return unless h.has_key? possible_question

  #   m.reply h[possible_question]
  # end

end

plugin = KQFAQ.new

plugin.map 'faq set :question *answer', :action => :set, :auth_path => 'faq::admin'
plugin.map 'faq unset :question', :action => :unset, :auth_path => 'faq::admin'
plugin.map 'faq list', :action => :list
plugin.map 'faq', :action => :list
plugin.map 'faq :question', :action => :get
plugin.map 'faq get :question', :action => :get

plugin.default_auth('faq::admin', false)
