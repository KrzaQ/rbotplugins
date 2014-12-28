# GB: Ok, we *really* need to switch to db for this plugin too

Quote = Struct.new("Quote", :num, :date, :source, :quote)

class QuotePlugin < Plugin
  def initialize
    super
    @oldquote = 0
    @lists = Hash.new
    Dir["#{@bot.botclass}/quotes/*"].each {|f|
      next if File.directory?(f)
      channel = File.basename(f)
      # @lists[channel] = Array.new if(!@lists.has_key?(channel))
      @lists[channel] = []
      IO.foreach(f) {|line|
        if(line =~ /^(\d+) \| ([^|]+) \| (\S+) \| (.*)$/)
          num = $1.to_i
          q = Quote.new(num, $2, $3, $4)
          @lists[channel][num] = q
        end
      }
    }
  end

  def save
    Dir.mkdir("#{@bot.botclass}/quotes") if(!FileTest.directory?("#{@bot.botclass}/quotes"))
    Dir.mkdir("#{@bot.botclass}/quotes/new") if(!FileTest.directory?("#{@bot.botclass}/quotes/new"))
    @lists.each {|channel, quotes|
      begin
        debug "Writing new quotefile for channel #{channel} ..."
        File.open("#{@bot.botclass}/quotes/new/#{channel}", "w") {|file|
          quotes.compact.each {|q|
            file.puts "#{q.num} | #{q.date} | #{q.source} | #{q.quote}"
          }
        }
        debug "Officializing quotefile for channel #{channel} ..."
        File.rename("#{@bot.botclass}/quotes/new/#{channel}",
                    "#{@bot.botclass}/quotes/#{channel}")
      rescue => e
        error "failed to write quotefile for channel #{channel}!\n#{$!}"
        error "#{e.class}: #{e}"
        error e.backtrace.join("\n")
      end
    }
  end

  def addquote(source, channel, quote)
    @lists[channel.to_s] = Array.new if(!@lists.has_key?(channel.to_s))
    num = @lists[channel.to_s].length
    @lists[channel.to_s][num] = Quote.new(num, Time.new, source, quote)
    save
    return num
  end

  def getquote(source, channel, num=nil)
    return nil unless(@lists.has_key?(channel.to_s))
    return nil unless(@lists[channel.to_s].length > 0)
    if(num)
      if(@lists[channel.to_s][num])
        return @lists[channel.to_s][num], @lists[channel.to_s].length - 1
      end
    else
      # random quote
      return @lists[channel.to_s].compact[rand(@lists[channel.to_s].nitems)],
      @lists[channel.to_s].length - 1
    end
  end

  def delquote(channel, num)
    return false unless(@lists.has_key?(channel.to_s))
    return false unless(@lists[channel.to_s].length > 0)
    if(@lists[channel.to_s][num])
      @lists[channel.to_s][num] = nil
      @lists[channel.to_s].pop if num == @lists[channel.to_s].length - 1
      save
      return true
    end
    return false
  end

  def countquote(source, channel=nil, regexp=nil)
    unless(channel)
      total=0
      @lists.each_value {|l|
        total += l.compact.length
      }
      return total
    end
    return 0 unless(@lists.has_key?(channel.to_s))
    return 0 unless(@lists[channel.to_s].length > 0)
    if(regexp)
      matches = @lists[channel.to_s].compact.find_all {|a| a.quote =~ /#{regexp}/i }
    else
      matches = @lists[channel.to_s].compact
    end
    return matches.length
  end

  def searchquote(source, channel, regexp)
    return nil unless(@lists.has_key?(channel.to_s))
    return nil unless(@lists[channel.to_s].length > 0)
    matches = @lists[channel.to_s].compact.find_all {|a| a.quote =~ /#{regexp}/i }

    randquote = rand(matches.length)

    if matches.length > 1
	while randquote == @oldquote
		randquote = rand(matches.length)
	end
    end
    @oldquote = randquote

    if(matches.length > 0)
      return matches[randquote], @lists[channel.to_s].length - 1, matches.length
    else
      return nil
    end
  end

  def help(plugin, topic="")
    case topic
    when "addquote"
      return "addquote [<channel>] <quote> => Add quote <quote> for channel <channel>. You only need to supply <channel> if you are addressing #{@bot.nick} privately. Responds to !addquote without addressing if so configured"
    when "delquote"
      return "delquote [<channel>] <num> => delete quote from <channel> with number <num>. You only need to supply <channel> if you are addressing #{@bot.nick} privately. Responds to !delquote without addressing if so configured"
    when "getquote"
      return "getquote [<channel>] [<num>] => get quote from <channel> with number <num>. You only need to supply <channel> if you are addressing #{@bot.nick} privately. Without <num>, a random quote will be returned. Responds to !getquote without addressing if so configured"
    when "searchquote"
      return "searchquote [<channel>] <regexp> => search for quote from <channel> that matches <regexp>. You only need to supply <channel> if you are addressing #{@bot.nick} privately. Responds to !searchquote without addressing if so configured"
    when "topicquote"
      return "topicquote [<channel>] [<num>] => set topic to quote from <channel> with number <num>. You only need to supply <channel> if you are addressing #{@bot.nick} privately. Without <num>, a random quote will be set. Responds to !topicquote without addressing if so configured"
    when "countquote"
      return "countquote [<channel>] <regexp> => count quotes from <channel> that match <regexp>. You only need to supply <channel> if you are addressing #{@bot.nick} privately. Responds to !countquote without addressing if so configured"
    when "whoquote"
      return "whoquote [<channel>] <num> => show who added quote <num>. You only need to supply <channel> if you are addressing #{@bot.nick} privately"
    when "whenquote"
      return "whenquote [<channel>] <num> => show when quote <num> was added. You only need to supply <channel> if you are addressing #{@bot.nick} privately"
    else
      return "Quote module (Quote storage and retrieval) topics: addquote, delquote, getquote, searchquote, topicquote, countquote, whoquote, whenquote"
    end
  end

  def listen(m)
    return unless(m.kind_of? PrivMessage)

    command = m.message.dup

    begin
      if(m.address? && m.private?)
        case command
          when (/^addquote\s+(#\S+)\s+(.*)/)
            channel = $1
            quote = $2
            if(@bot.auth.allow?("addquote", m.source, m.replyto))
              if(channel =~ /^#/)
                num = addquote(m.source, channel, quote)
                m.reply "added the quote (##{num})"
              end
            end
          when (/^getquote\s+(#\S+)$/)
            channel = $1
            if(@bot.auth.allow?("getquote", m.source, m.replyto))
              quote, total = getquote(m.source, channel)
              if(quote)
                m.reply "[#{quote.num}] #{quote.quote}"
              else
                m.reply "quote not found!"
              end
            end
          when (/^getquote\s+(#\S+)\s+(\d+)$/)
            channel = $1
            num = $2.to_i
            if(@bot.auth.allow?("getquote", m.source, m.replyto))
              quote, total = getquote(m.source, channel, num)
              if(quote)
                m.reply "[#{quote.num}] #{quote.quote}"
              else
                m.reply "quote not found!"
              end
            end
          when (/^whoquote\s+(#\S+)\s+(\d+)$/)
            channel = $1
            num = $2.to_i
            if(@bot.auth.allow?("getquote", m.source, m.replyto))
              quote, total = getquote(m.source, channel, num)
              if(quote)
                m.reply "quote #{quote.num} added by #{quote.source}"
              else
                m.reply "quote not found!"
              end
            end
          when (/^whenquote\s+(#\S+)\s+(\d+)$/)
            channel = $1
            num = $2.to_i
            if(@bot.auth.allow?("getquote", m.source, m.replyto))
              quote, total = getquote(m.source, channel, num)
              if(quote)
                m.reply "quote #{quote.num} added on #{quote.date}"
              else
                m.reply "quote not found!"
              end
            end
          when (/^topicquote\s+(#\S+)$/)
            channel = $1
            if(@bot.auth.allow?("topicquote", m.source, m.replyto))
              quote, total = getquote(m.source, channel)
              if(quote)
                @bot.topic channel, "[#{quote.num}] #{quote.quote}"
              else
                m.reply "quote not found!"
              end
            end
          when (/^topicquote\s+(#\S+)\s+(\d+)$/)
            channel = $1
            num = $2.to_i
            if(@bot.auth.allow?("topicquote", m.source, m.replyto))
              quote, total = getquote(m.source, channel, num)
              if(quote)
                @bot.topic channel, "[#{quote.num}] #{quote.quote}"
              else
                m.reply "quote not found!"
              end
            end
          when (/^delquote\s+(#\S+)\s+(\d+)$/)
            m.reply "Sorry mate, I cannot into deletions"
            return
            channel = $1
            num = $2.to_i
            if(@bot.auth.allow?("delquote", m.source, m.replyto))
              if(delquote(channel, num))
                m.okay
              else
                m.reply "quote not found!"
              end
            end
          when (/^searchquote\s+(#\S+)\s+(.*)$/)
            channel = $1
            reg = $2
            if(@bot.auth.allow?("getquote", m.source, m.replyto))
              quote, total = searchquote(m.source, channel, reg)
              if(quote)
                m.reply "[#{quote.num}] #{quote.quote}"
              else
                m.reply "quote not found!"
              end
            end
          when (/^countquote$/)
            if(@bot.auth.allow?("getquote", m.source, m.replyto))
              total = countquote(m.source)
              m.reply "#{total} quotes"
            end
          when (/^countquote\s+(#\S+)\s*(.*)$/)
            channel = $1
            reg = $2
            if(@bot.auth.allow?("getquote", m.source, m.replyto))
              total = countquote(m.source, channel, reg)
              if(reg.length > 0)
                m.reply "#{total} quotes match: #{reg}"
              else
                m.reply "#{total} quotes"
              end
            end
        end
      elsif (m.address? || (@bot.config["QUOTE_LISTEN"] || command.gsub!(/!/, "")))
        case command
          when (/^addquote\s+(.+)/)
            if(@bot.auth.allow?("addquote", m.source, m.replyto))
              num = addquote(m.source, m.target, $1)
              m.reply "added the quote (##{num})"
            end
          when (/^getquote$/)
            if(@bot.auth.allow?("getquote", m.source, m.replyto))
              quote, total = getquote(m.source, m.target)
              if(quote)
                m.reply "[#{quote.num}] #{quote.quote}"
              else
                m.reply "no quotes found!"
              end
            end
          when (/^getquote\s+(\d+)$/)
            num = $1.to_i
            if(@bot.auth.allow?("getquote", m.source, m.replyto))
              quote, total = getquote(m.source, m.target, num)
              if(quote)
                m.reply "[#{quote.num}] #{quote.quote}"
              else
                m.reply "quote not found!"
              end
            end
          when (/^whenquote\s+(\d+)$/)
            num = $1.to_i
            if(@bot.auth.allow?("getquote", m.source, m.replyto))
              quote, total = getquote(m.source, m.target, num)
              if(quote)
                m.reply "quote #{quote.num} added on #{quote.date}"
              else
                m.reply "quote not found!"
              end
            end
          when (/^whoquote\s+(\d+)$/)
            num = $1.to_i
            if(@bot.auth.allow?("getquote", m.source, m.replyto))
              quote, total = getquote(m.source, m.target, num)
              if(quote)
                m.reply "quote #{quote.num} added by #{quote.source}"
              else
                m.reply "quote not found!"
              end
            end
          when (/^topicquote$/)
            if(@bot.auth.allow?("topicquote", m.source, m.replyto))
              quote, total = getquote(m.source, m.target)
              if(quote)
                @bot.topic m.target, "[#{quote.num}] #{quote.quote}"
              else
                m.reply "no quotes found!"
              end
            end
          when (/^topicquote\s+(\d+)$/)
            num = $1.to_i
            if(@bot.auth.allow?("topicquote", m.source, m.replyto))
              quote, total = getquote(m.source, m.target, num)
              if(quote)
                @bot.topic m.target, "[#{quote.num}] #{quote.quote}"
              else
                m.reply "quote not found!"
              end
            end
          when (/^delquote\s+(\d+)$/)
            m.reply "sorry mate, I cannot into deleting quotes"
            return
            num = $1.to_i
            if(@bot.auth.allow?("delquote", m.source, m.replyto))
              if(delquote(m.target, num))
                m.okay
              else
                m.reply "quote not found!"
              end
            end
          when (/^searchquote\s+(.*)$/)
            reg = $1
            if(@bot.auth.allow?("getquote", m.source, m.replyto))
              quote, total, match = searchquote(m.source, m.target, reg)
              if(quote)
                m.reply "[#{quote.num} (#{match})] #{quote.quote}"
              else
                m.reply "quote not found!"
              end
            end
          when (/^countquote(?:\s+(.*))?$/)
            reg = $1
            if(@bot.auth.allow?("getquote", m.source, m.replyto))
              total = countquote(m.source, m.target, reg)
              if(reg && reg.length > 0)
                m.reply "#{total} quotes match: #{reg}"
              else
                m.reply "#{total} quotes"
              end
            end
        end
      end
    rescue => e
      m.reply "Exception: #{e}"
    end
  end
end
plugin = QuotePlugin.new
plugin.register("quotes")