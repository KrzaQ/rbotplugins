require 'json'
require 'httpclient'
require 'thread'

Link = 'http://4programmers.net/api/topic.php?key=%{api_key}&start_id=%{last_id}'

class FourPLister < Plugin

	Config.register Config::FloatValue.new 'fourplister.refresh_delay',
		default: 1.0,
		desc: 'Refresh delay'
	
	Config.register Config::ArrayValue.new 'fourplister.sought_tags',
		default: ['c++', 'c', 'r', 'd', 'qt', 'asm'],
		desc: 'Tags'

	Config.register Config::ArrayValue.new 'fourplister.sought_fora',
		default: ['C/C++'],
		desc: 'Fora'

	Config.register Config::ArrayValue.new 'fourplister.sought_phrases',
		default: ['c++'],
		desc: 'Phrases'

	def initialize
		super
		@registry['last_id'] = 269685 unless @registry.has_key? 'last_id'

		@key = @bot.config['fourplister.api_key']

		Thread.new {
			sleep 45
			start_timer
		}
	end

	def start_timer
		@timer = @bot.timer.add_once(@bot.config['fourplister.refresh_delay'].to_f){
			start_timer
		}
		refresh
	end

	def refresh
		c = HTTPClient.new
		raw = c.get_content(Link % {
			api_key: @bot.config['fourplister.api_key'],
			last_id: @registry['last_id']
		})
		d = JSON.parse raw
		
		d.select{ |el|
			t = (el['tags'] & @bot.config['fourplister.sought_tags']).size > 0
			f = @bot.config['fourplister.sought_fora'].include? el['forum']
			#p = @bot.config['fourplister.sought_phrases'].include? el['forum']
			t || f
		}.each do |el|
			notify_channels el
		end

		@registry['last_id'] = d.map{|el| el['id'] }.max unless d.size < 1
		@registry.flush
	end

	def notify_channels(el)
		p el
		parts = {
			topic: "#{Bold}#{Irc.color(:green)}%{subject}#{Irc.color}#{Bold}" % el,
			url: "#{Irc.color(:red)}http://4programmers.net/%{id}#{Irc.color}" % el,
			tags: "(#{Irc.color(:darkgray)}%s#{Irc.color})" % el['tags'].join(', '),
			forum: "#{Bold}#{Irc.color(:darkgray)}[%{forum}]#{Irc.color}#{Bold}" % el
		}

		msg = '%{forum} %{topic} %{tags}' % parts

		@bot.say '#4programmers', msg
		@bot.say '#4programmers', parts[:url]
	end
end

plugin = FourPLister.new
