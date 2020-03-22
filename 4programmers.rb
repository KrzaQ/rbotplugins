require 'json'
require 'httpclient'
require 'cgi'

class FourPLister < Plugin

	@@link = 'https://api.4programmers.net/v1/topics'

	Config.register Config::FloatValue.new 'fourplister.refresh_delay',
		default: 1.0,
		desc: 'Refresh delay'

	Config.register Config::ArrayValue.new 'fourplister.sought_tags',
		default: ['c++', 'cpp',  'c', 'ruby', 'd', 'qt', 'asm'],
		desc: 'Tags'

	Config.register Config::ArrayValue.new 'fourplister.sought_fora',
		default: ['C/C++'],
		desc: 'Fora'

	Config.register Config::ArrayValue.new 'fourplister.sought_phrases',
		default: ['c++'],
		desc: 'Phrases'

	Config.register Config::StringValue.new 'fourplister.api_key',
		desc: 'Api Key'

	def initialize
		super
		@registry['last_id'] = 278348 unless @registry.has_key? 'last_id'

		@key = @bot.config['fourplister.api_key']

		Thread.new {
			sleep 45
			start_timer
		}

		@done = false
	end

	def cleanup
		@done = true
		super
	end

	def start_timer
		return if @done
		@timer = @bot.timer.add_once(@bot.config['fourplister.refresh_delay'].to_f){
			start_timer unless @done
		}
		refresh
	end

	def refresh
		c = HTTPClient.new
		raw = c.get_content(@@link % {
			api_key: @key,
			last_id: @registry['last_id']
		})
		d = JSON.parse(raw, symbolize_names: true)

		topics = d[:data].select do |el|
			t = (
				el[:tags].map{ |t| t[:name] } &
				@bot.config['fourplister.sought_tags']
			).size > 0

			f = @bot.config['fourplister.sought_fora'].include? el[:forum][:name]
			t || f
		end.reverse.map do |el|
			{
				topic_id: el[:id],
				topic_url: el[:url],
				first_post_id: el[:first_post_id],
				subject: el[:subject],
				forum: el[:forum][:name],
				tags: el[:tags].map{ |t| t[:name] },
			}
		end.reject do |el|
			el[:topic_id] <= @registry['last_id'].to_i
		end

		topics.each do |el|
			notify_channels el
			warn el.inspect
		end

		@registry['last_topic'] = topics.last unless topics.size < 1
		@registry['last_id'] = topics.map{ |el| el[:topic_id] }.max unless topics.size < 1
		@registry.flush
	end

	def notify_channels(el)
		p el
		parts = {
			topic: "#{Bold}#{Irc.color(:green)}%{subject}#{Irc.color}#{Bold}" % el,
			url: "#{Irc.color(:red)}https://4programmers.net/Forum/%{first_post_id}#{Irc.color}" % el,
			tags: "(#{Irc.color(:darkgray)}%s#{Irc.color})" % el[:tags].join(', '),
			forum: "#{Bold}#{Irc.color(:darkgray)}[%{forum}]#{Irc.color}#{Bold}" % el
		}

		msg = '%{forum} %{topic} %{tags}' % parts

		@bot.say '#4programmers', msg
		@bot.say '#4programmers', parts[:url]
	end

	def get_last(m, params)
		t = @registry['last_topic']
		if t
			notify_channels t
		else
			m.reply 'no last known topic'
		end
	end
end

plugin = FourPLister.new

plugin.map '4p last', action: :get_last

