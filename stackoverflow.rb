require 'json'
require 'httpclient'
require 'zlib'
require 'stringio'

class StackOverflow < Plugin
	@@api_link = 'https://api.stackexchange.com/2.2/questions?order=desc&sort=creation&site=stackoverflow&pagesize=100'

	Config.register Config::FloatValue.new 'stackoverflower.refresh_delay',
		default: 12.0,
		desc: 'Refresh delay'

	Config.register Config::IntegerValue.new 'stackoverflower.displayed_queue',
		default: 1024,
		desc: 'Displayed queue'

	def initialize
		super
		# @registry['last_id'] = 278348 unless @registry.has_key? 'last_id'
		@registry['displayed'] = [] unless @registry.has_key? 'displayed'

		Thread.new {
			sleep 45
			start_timer
		}

		@done = false
	end

	def start_timer
		return if @done
		@timer = @bot.timer.add_once(@bot.config['stackoverflower.refresh_delay'].to_f){
			start_timer
		}
		refresh
	end

	def cleanup
		@bot.say '#4programmers', 'so cleanup = done'
		@done = true
	end

	def refresh
		qs = get_questions['items']

		disp = @registry['displayed']

		wanted = qs.reject{ |el|
			disp.include? el['question_id']
		}.select{ |el|
			is_wanted_question(el)
		}

		wanted.each do |el|
			disp.push el['question_id']
			notify_channels el
		end

		if disp.size > @bot.config['stackoverflower.displayed_queue']
			over = disp.size - @bot.config['stackoverflower.displayed_queue']
			disp = disp[over..-1]
		end

		@registry['displayed'] = disp
	end

	def is_wanted_question(q)

		# p q['title']

		return true if q['tags'].include? 'c++98'
		return true if q['tags'].include? 'c++03'
		return true if q['tags'].include? 'c++11'
		return true if q['tags'].include? 'c++14'
		return true if q['tags'].include? 'c++17'

		if q['tags'].include? 'c++'
			return true if q['owner']['reputation'].to_i >= 150
			return true if q['tags'].include? 'language-lawyer'
			return true if q['tags'].include? 'qt'
			return true if q['tags'].include? 'templates'
			return true if q['tags'].include? 'variadic-templates'
		end

		false
	end

	def get_questions
		zipped = HTTPClient.new.get_content @@api_link
		json = Zlib::GzipReader.new(StringIO.new(zipped)).read
		d = JSON.parse json
		d
	end

	def notify_channels(el)
		p el
		parts = {
			topic: "#{Bold}#{Irc.color(:darkgray)}%{title}#{Irc.color}#{Bold}" % el,
			url: "#{Irc.color(:red)}%{link}#{Irc.color}" % { link: el['link'].sub(/(https?:\/\/stackoverflow.com\/questions\/\d+\/).+/, '\1') },
			tags: "(#{Irc.color(:darkgray)}%s#{Irc.color})" % el['tags'].join(', '),
			# forum: "#{Bold}#{Irc.color(:darkgray)}[%{forum}]#{Irc.color}#{Bold}" % el
			forum: "[SO]",
			rep: "(#{Irc.color(:darkgray)}Rep: %s#{Irc.color})" % el['owner']['reputation']
		}

		msg = '%{forum} %{topic} %{tags} %{rep}' % parts

		@bot.say '#4programmers', msg
		@bot.say '#4programmers', parts[:url]
	end

end

plugin = StackOverflow.new