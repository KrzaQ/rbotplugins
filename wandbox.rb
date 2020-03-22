require 'httpclient'
require 'json'
require 'optparse'

LANGUAGE_SHORTCUTS = {
    cpp: 'C++',
    c: 'C',
    rb: 'Ruby',
    py: 'Python',
}

class WandboxAPI
    
    def initialize
        @cache = nil
    end

    def get_languages
        get_list.map do |el|
            el[:language]
        end.sort.uniq
    end

    def get_versions lang
        get_list.select do |el|
            el[:language].downcase == lang.downcase
        end.map do |el|
            el[:name]
        end
    end

    def compile code, lang, version = nil
        c = HTTPClient.new
        url = 'https://wandbox.org/api/compile.json'

        compiler = if version
            version
        else
            get_list unless @cache
            el = @cache.find{ |el| el[:language].upcase == lang.upcase }
            raise "Copmiler not found" unless el
            el[:name]
        end

        body = {
            compiler: compiler,
            code: code,
        }
        headers = {
            'Content-Type' => 'application/json',
        }
        ret = c.post url, body.to_json, headers
        raise ret.body unless ret.code == 200
        result = JSON.parse ret.body, symbolize_names: true
        raise result[:program_message] unless result[:status].to_i == 0
        (result[:program_message] || '').strip
    end

    def get_list
        c = HTTPClient.new
        url = 'https://wandbox.org/api/list.json'
        r = c.get url
        raise r.body if r.code != 200
        @cache = JSON.parse r.body, symbolize_names: true
        @cache
    end

end

if __FILE__ == $0
    require 'ostruct'
    class Plugin
        def initialize
            @bot = OpenStruct.new
            @bot.config = { }
        end
        def map *a
        end
    end
end

class Wandbox < Plugin
    attr_accessor :wandbox

    def initialize
        super
        self.wandbox = WandboxAPI.new
    end

    def help(plugin, topic="")
        handle_message 'eval --help'
    end

    def message(m)
        return unless m.prefixed?
        ret = handle_message m.message
        return unless ret
        m.reply ret.split("\n").take(5).join("\n")
    end

    def handle_message msg
        begin
            parsed = parse_message msg
            return unless parsed
            case parsed[:mode]
            when :help
                parsed[:message]
            when :list
                if parsed[:language]
                    self.wandbox.get_versions(parsed[:language]).join(', ')
                else
                    self.wandbox.get_languages.join(', ')
                end
            when :compile
                params = %i(code language compiler).map{ |s| parsed[s] }
                self.wandbox.compile *params
            else
                nil
            end
        rescue => e
            puts e.backtrace
            "Failed: #{e.message}"
        end
    end

    def parse_message msg
        argv = msg.split
        argv.shift
        case msg
        when /^eval\.(\w+)/
            lang = $1.downcase.to_sym
            full_lang = LANGUAGE_SHORTCUTS[lang]
            raise "Unknown language: #{$1}" unless full_lang
            parse argv, full_lang
        when /^eval /
            parse argv
        else
            nil
        end
    end

    def parse argv, lang = nil
        ret = {
            language: lang,
            mode: lang ? :compile : :help,
            compiler: nil,
        }
        op = OptionParser.new do |o|
            o.banner = 'Wandbox compiler. Usage: eval [params] code. <\\n> for newline'
            o.on('--lang L'){ |v| ret[:language] = v }
            o.on('--list [LANG]'){ |v| ret[:mode] = :list; ret[:language] = v if v }
            o.on('--compiler C'){ |v| ret[:compiler] = v }
            o.on('--help'){ |v| ret[:mode] = :help }
        end
        rest = op.parse argv
        ret[:message] = op.help if ret[:mode] == :help
        ret[:code] = rest.join(' ').gsub("<\\n>", "\n")
        ret[:mode] = :compile if (ret[:language] or ret[:compiler]) and not lang
        ret
    end
end

plugin = Wandbox.new

if __FILE__ == $0
    begin
        # a = WandboxAPI.new
        # ret = a.compile 'puts 123x', 'Ruby'
        # p ret
        # p a.get_languages
        # list = a.get_versions 'Ruby'
        # list.each do |el|
            # p el
        # end

        # ret = plugin.handle_message 'eval #include <iostream>\nint main(){ std::cout << "test"; }'
        ret = plugin.handle_message 'eval --compiler=gcc-1.27-c #include <stdio.h><\n> int main(void){ printf("Hello, wandbox!"); return 0; }'
        # ret = plugin.handle_message 'eval --help'
        puts ret

        # p ret
        # c.get_data[:features].each do |x|
            # p x
        # end
        # r = plugin.parse "--no-color".split
        # p r
        # p plugin.get_data r
        # p plugin.convert r
    rescue => e
        puts e
        puts e.backtrace
    end
end
