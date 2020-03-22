require 'json'
require 'httpclient'
require 'zlib'
require 'stringio'
require 'cgi'

class StackOverflow < Plugin
	@@api_link = 'https://api.stackexchange.com/2.2/questions?key=%{key}&order=desc&sort=creation&site=stackoverflow&pagesize=100'

	Config.register Config::FloatValue.new 'stackoverflower.refresh_delay',
		default: 12.0,
		desc: 'Refresh delay'

	Config.register Config::IntegerValue.new 'stackoverflower.displayed_queue',
		default: 1024,
		desc: 'Displayed queue'

	Config.register Config::StringValue.new 'stackoverflower.api_key',
		desc: 'Api Key'

	def initialize
		super
		# @registry['last_id'] = 278348 unless @registry.has_key? 'last_id'
		@registry['displayed'] = [] unless @registry.has_key? 'displayed'

		@key = @bot.config['stackoverflower.api_key']

		Thread.new {
			sleep 45
			start_timer
		}

		@done = false

		@status = :off
	end

	def start_timer
		return if @done
		@timer = @bot.timer.add_once(@bot.config['stackoverflower.refresh_delay'].to_f){
			start_timer
		}
		refresh
	end

	def cleanup
		@done = true
		super
	end

	def refresh
		return if @status == :off

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
		return false if q['tags'].include? 'cocos2d'
		return false if q['tags'].include? 'android'

		return true if q['tags'].include? 'c++98'
		return true if q['tags'].include? 'c++03'
		return true if q['tags'].include? 'c++11'
		return true if q['tags'].include? 'c++14'
		return true if q['tags'].include? 'c++17'
		return true if q['tags'].include? 'c++1z'
		return true if q['tags'].include? 'd'

		if q['tags'].include? 'c++'
			return true if q['owner']['reputation'].to_i >= 150
			return true if q['tags'].include? 'language-lawyer'
			return true if q['tags'].include? 'metaprogramming'
			return true if q['tags'].include? 'qt'
			return true if q['tags'].include? 'templates'
			return true if q['tags'].include? 'template-meta-programming'
			return true if q['tags'].include? 'variadic-templates'
		end

		false
	end

	def get_questions
		zipped = HTTPClient.new.get_content(@@api_link % {key: @key})
		json = Zlib::GzipReader.new(StringIO.new(zipped)).read
		d = JSON.parse json
		d
	end

	def notify_channels(el)
		p el
		parts = {
			topic: "#{Bold}#{Irc.color(:teal)}%{title}#{Irc.color}#{Bold}" % { title: CGI.unescapeHTML(el['title']) },
			url: "#{Irc.color(:red)}%{link}#{Irc.color}" % { link: el['link'].sub(/(https?:\/\/stackoverflow.com\/questions\/\d+\/).+/, '\1') },
			tags: "(#{Irc.color(:darkgray)}%s#{Irc.color})" % el['tags'].join(', '),
			forum: "[SO]",
			rep: "(#{Irc.color(:darkgray)}Rep: %s#{Irc.color})" % el['owner']['reputation']
		}

		msg = '%{forum} %{topic} %{tags} %{rep}' % parts

		@bot.say '#4programmers', msg
		@bot.say '#4programmers', parts[:url]
	end

	def turn_on(m, p)
		@status = :on
  		m.okay
	end

	def turn_off(m, p)
		@status = :off
   		m.okay
	end

end

plugin = StackOverflow.new

plugin.map 'so on', :action => :turn_on, :auth_path => 'stackoverflow'
plugin.map 'so off', :action => :turn_off, :auth_path => 'stackoverflow'
plugin.default_auth('stackoverflow', false)
