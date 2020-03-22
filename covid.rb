require 'httpclient'
require 'json'
require 'optparse'

COUNTRIES = {
    "AF" => "AFGHANISTAN",
    "AX" => "ÅLAND ISLANDS",
    "AL" => "ALBANIA",
    "DZ" => "ALGERIA",
    "AS" => "AMERICAN SAMOA",
    "AD" => "ANDORRA",
    "AO" => "ANGOLA",
    "AI" => "ANGUILLA",
    "AQ" => "ANTARCTICA",
    "AG" => "ANTIGUA AND BARBUDA",
    "AR" => "ARGENTINA",
    "AM" => "ARMENIA",
    "AW" => "ARUBA",
    "AU" => "AUSTRALIA",
    "AT" => "AUSTRIA",
    "AZ" => "AZERBAIJAN",
    "BS" => "BAHAMAS, THE",
    "BH" => "BAHRAIN",
    "BD" => "BANGLADESH",
    "BB" => "BARBADOS",
    "BY" => "BELARUS",
    "BE" => "BELGIUM",
    "BZ" => "BELIZE",
    "BJ" => "BENIN",
    "BM" => "BERMUDA",
    "BT" => "BHUTAN",
    "BO" => "BOLIVIA",
    "BQ" => "BONAIRE",
    "BA" => "BOSNIA AND HERZEGOVINA",
    "BW" => "BOTSWANA",
    "BV" => "BOUVET ISLAND",
    "BR" => "BRAZIL",
    "IO" => "BRITISH INDIAN OCEAN TERRITORY",
    "BN" => "BRUNEI",
    "BG" => "BULGARIA",
    "BF" => "BURKINA FASO",
    "BI" => "BURUNDI",
    "KH" => "CAMBODIA",
    "CM" => "CAMEROON",
    "CA" => "CANADA",
    "CV" => "CAPE VERDE",
    "KY" => "CAYMAN ISLANDS",
    "CF" => "CENTRAL AFRICAN REPUBLIC",
    "TD" => "CHAD",
    "CL" => "CHILE",
    "CN" => "CHINA",
    "CX" => "CHRISTMAS ISLAND",
    "CC" => "COCOS ISLANDS",
    "CO" => "COLOMBIA",
    "KM" => "COMOROS",
    "CG" => "CONGO (BRAZZAVILLE)",
    "CD" => "CONGO (KINSHASA)",
    "CK" => "COOK ISLANDS",
    "CR" => "COSTA RICA",
    "CI" => "CÔTE D'IVOIRE",
    "HR" => "CROATIA",
    "CU" => "CUBA",
    "CW" => "CURAÇAO",
    "CY" => "CYPRUS",
    "CZ" => "CZECHIA",
    "DK" => "DENMARK",
    "DJ" => "DJIBOUTI",
    "DM" => "DOMINICA",
    "DO" => "DOMINICAN REPUBLIC",
    "EC" => "ECUADOR",
    "EG" => "EGYPT",
    "SV" => "EL SALVADOR",
    "GQ" => "EQUATORIAL GUINEA",
    "ER" => "ERITREA",
    "EE" => "ESTONIA",
    "ET" => "ETHIOPIA",
    "FK" => "FALKLAND ISLANDS",
    "FO" => "FAROE ISLANDS",
    "FJ" => "FIJI",
    "FI" => "FINLAND",
    "FR" => "FRANCE",
    "GF" => "GUIANA",
    "PF" => "POLYNESIA",
    "TF" => "FRENCH SOUTHERN TERRITORIES",
    "GA" => "GABON",
    "GM" => "GAMBIA, THE",
    "GE" => "GEORGIA",
    "DE" => "GERMANY",
    "GH" => "GHANA",
    "GI" => "GIBRALTAR",
    "GR" => "GREECE",
    "GL" => "GREENLAND",
    "GD" => "GRENADA",
    "GP" => "GUADELOUPE",
    "GU" => "GUAM",
    "GT" => "GUATEMALA",
    "GG" => "GUERNSEY",
    "GN" => "GUINEA",
    "GW" => "GUINEA-BISSAU",
    "GY" => "GUYANA",
    "HT" => "HAITI",
    "HM" => "HEARD ISLAND AND MCDONALD ISLANDS",
    "VA" => "HOLY SEE",
    "HN" => "HONDURAS",
    "HK" => "HONG KONG",
    "HU" => "HUNGARY",
    "IS" => "ICELAND",
    "IN" => "INDIA",
    "ID" => "INDONESIA",
    "IR" => "IRAN",
    "IQ" => "IRAQ",
    "IE" => "IRELAND",
    "IM" => "ISLE OF MAN",
    "IL" => "ISRAEL",
    "IT" => "ITALY",
    "JM" => "JAMAICA",
    "JP" => "JAPAN",
    "JE" => "JERSEY",
    "JO" => "JORDAN",
    "KZ" => "KAZAKHSTAN",
    "KE" => "KENYA",
    "KI" => "KIRIBATI",
    "KP" => "KOREA, NORTH",
    "KR" => "KOREA, SOUTH",
    "KW" => "KUWAIT",
    "KG" => "KYRGYZSTAN",
    "LA" => "LAOS",
    "LV" => "LATVIA",
    "LB" => "LEBANON",
    "LS" => "LESOTHO",
    "LR" => "LIBERIA",
    "LY" => "LIBYA",
    "LI" => "LIECHTENSTEIN",
    "LT" => "LITHUANIA",
    "LU" => "LUXEMBOURG",
    "MO" => "MACAO",
    "MK" => "NORTH MACEDONIA",
    "MG" => "MADAGASCAR",
    "MW" => "MALAWI",
    "MY" => "MALAYSIA",
    "MV" => "MALDIVES",
    "ML" => "MALI",
    "MT" => "MALTA",
    "MH" => "MARSHALL ISLANDS",
    "MQ" => "MARTINIQUE",
    "MR" => "MAURITANIA",
    "MU" => "MAURITIUS",
    "YT" => "MAYOTTE",
    "MX" => "MEXICO",
    "FM" => "MICRONESIA",
    "MD" => "MOLDOVA",
    "MC" => "MONACO",
    "MN" => "MONGOLIA",
    "ME" => "MONTENEGRO",
    "MS" => "MONTSERRAT",
    "MA" => "MOROCCO",
    "MZ" => "MOZAMBIQUE",
    "MM" => "MYANMAR",
    "NA" => "NAMIBIA",
    "NR" => "NAURU",
    "NP" => "NEPAL",
    "NL" => "NETHERLANDS",
    "NC" => "NEW CALEDONIA",
    "NZ" => "NEW ZEALAND",
    "NI" => "NICARAGUA",
    "NE" => "NIGER",
    "NG" => "NIGERIA",
    "NU" => "NIUE",
    "NF" => "NORFOLK ISLAND",
    "MP" => "NORTHERN MARIANA ISLANDS",
    "NO" => "NORWAY",
    "OM" => "OMAN",
    "PK" => "PAKISTAN",
    "PW" => "PALAU",
    "PS" => "PALESTINE, STATE OF",
    "PA" => "PANAMA",
    "PG" => "PAPUA NEW GUINEA",
    "PY" => "PARAGUAY",
    "PE" => "PERU",
    "PH" => "PHILIPPINES",
    "PN" => "PITCAIRN",
    "PL" => "POLAND",
    "PT" => "PORTUGAL",
    "PR" => "PUERTO RICO",
    "QA" => "QATAR",
    "RE" => "RÉUNION",
    "RO" => "ROMANIA",
    "RU" => "RUSSIA",
    "RW" => "RWANDA",
    "BL" => "SAINT BARTHÉLEMY",
    "SH" => "SAINT HELENA",
    "KN" => "SAINT KITTS AND NEVIS",
    "LC" => "SAINT LUCIA",
    "MF" => "SAINT MARTIN",
    "PM" => "SAINT PIERRE AND MIQUELON",
    "VC" => "SAINT VINCENT AND THE GRENADINES",
    "WS" => "SAMOA",
    "SM" => "SAN MARINO",
    "ST" => "SAO TOME AND PRINCIPE",
    "SA" => "SAUDI ARABIA",
    "SN" => "SENEGAL",
    "RS" => "SERBIA",
    "SC" => "SEYCHELLES",
    "SL" => "SIERRA LEONE",
    "SG" => "SINGAPORE",
    "SX" => "SINT MAARTEN",
    "SK" => "SLOVAKIA",
    "SI" => "SLOVENIA",
    "SB" => "SOLOMON ISLANDS",
    "SO" => "SOMALIA",
    "ZA" => "SOUTH AFRICA",
    "GS" => "GEORGIA",
    "SS" => "SOUTH SUDAN",
    "ES" => "SPAIN",
    "LK" => "SRI LANKA",
    "SD" => "SUDAN",
    "SR" => "SURINAME",
    "SJ" => "SVALBARD AND JAN MAYEN",
    "SZ" => "SWAZILAND",
    "SE" => "SWEDEN",
    "CH" => "SWITZERLAND",
    "SY" => "SYRIA",
    "TW" => "TAIWAN",
    "TJ" => "TAJIKISTAN",
    "TZ" => "TANZANIA",
    "TH" => "THAILAND",
    "TL" => "TIMOR-LESTE",
    "TG" => "TOGO",
    "TK" => "TOKELAU",
    "TO" => "TONGA",
    "TT" => "TRINIDAD AND TOBAGO",
    "TN" => "TUNISIA",
    "TR" => "TURKEY",
    "TM" => "TURKMENISTAN",
    "TC" => "TURKS AND CAICOS ISLANDS",
    "TV" => "TUVALU",
    "UG" => "UGANDA",
    "UA" => "UKRAINE",
    "AE" => "UNITED ARAB EMIRATES",
    "GB" => "UNITED KINGDOM",
    "UK" => "UNITED KINGDOM",
    "US" => "US",
    "UM" => "UNITED STATES MINOR OUTLYING ISLANDS",
    "UY" => "URUGUAY",
    "UZ" => "UZBEKISTAN",
    "VU" => "VANUATU",
    "VE" => "VENEZUELA",
    "VN" => "VIETNAM",
    "VG" => "VIRGIN ISLANDS",
    "VI" => "VIRGIN ISLANDS",
    "WF" => "WALLIS AND FUTUNA",
    "EH" => "WESTERN SAHARA",
    "YE" => "YEMEN",
    "ZM" => "ZAMBIA",
    "ZW" => "ZIMBABWE",
}

STATES = {
    'AK' => 'ALASKA',
    'AL' => 'ALABAMA',
    'AR' => 'ARKANSAS',
    'AS' => 'AMERICAN SAMOA',
    'AZ' => 'ARIZONA',
    'CA' => 'CALIFORNIA',
    'CO' => 'COLORADO',
    'CT' => 'CONNECTICUT',
    'DC' => 'DISTRICT OF COLUMBIA',
    'DE' => 'DELAWARE',
    'FL' => 'FLORIDA',
    'GA' => 'GEORGIA',
    'GA-state' => 'GEORGIA',
    'GU' => 'GUAM',
    'HI' => 'HAWAII',
    'IA' => 'IOWA',
    'ID' => 'IDAHO',
    'IL' => 'ILLINOIS',
    'IN' => 'INDIANA',
    'KS' => 'KANSAS',
    'KY' => 'KENTUCKY',
    'LA' => 'LOUISIANA',
    'MA' => 'MASSACHUSETTS',
    'MD' => 'MARYLAND',
    'ME' => 'MAINE',
    'MI' => 'MICHIGAN',
    'MN' => 'MINNESOTA',
    'MO' => 'MISSOURI',
    'MP' => 'NORTHERN MARIANA ISLANDS',
    'MS' => 'MISSISSIPPI',
    'MT' => 'MONTANA',
    'NA' => 'NATIONAL',
    'NC' => 'NORTH CAROLINA',
    'ND' => 'NORTH DAKOTA',
    'NE' => 'NEBRASKA',
    'NH' => 'NEW HAMPSHIRE',
    'NJ' => 'NEW JERSEY',
    'NM' => 'NEW MEXICO',
    'NV' => 'NEVADA',
    'NY' => 'NEW YORK',
    'OH' => 'OHIO',
    'OK' => 'OKLAHOMA',
    'OR' => 'OREGON',
    'PA' => 'PENNSYLVANIA',
    'PR' => 'PUERTO RICO',
    'RI' => 'RHODE ISLAND',
    'SC' => 'SOUTH CAROLINA',
    'SD' => 'SOUTH DAKOTA',
    'TN' => 'TENNESSEE',
    'TX' => 'TEXAS',
    'UT' => 'UTAH',
    'VA' => 'VIRGINIA',
    'VI' => 'VIRGIN ISLANDS',
    'VT' => 'VERMONT',
    'WA' => 'WASHINGTON',
    'WI' => 'WISCONSIN',
    'WV' => 'WEST VIRGINIA',
    'WY' => 'WYOMING',
}

class CovidAPI
    
    def initialize
    end

    def get_global
        {
            region: nil,
            data: format_data(get_data[:features]),
        }
    end

    def get_from_region region
        country = COUNTRIES.find{ |k, v| [k, v].include? region.upcase }
        state = STATES.find{ |k, v| [k, v].include? region.upcase }

        data = get_data[:features].select do |f|
            search_predicate f, region, country, state
        end
        
        raise "Region #{region} not found" unless data.size > 0

        {
            region: COUNTRIES.fetch(region, STATES.fetch(region, region)),
            data: format_data(data),
        }
    end

    def format_data data
        funcs = [ :sum, :sum, :sum, :sum, :max ]
        data.map do |f|
            extract_attrib f
        end.transpose.zip(funcs).map do |zips|
            zips.first.reduce{ |t, n| [t, n].send zips.last }
        end
    end

    def search_predicate attrib, region, country, state
        if country
            (attrib[:attributes][:Country_Region] || "").upcase == country.last
        elsif state
            (attrib[:attributes][:Province_State] || "").upcase == state.last
        else
            false
        end
    end

    def extract_attrib elem
        %i(Confirmed Deaths Recovered Active Last_Update).map do |k|
            elem[:attributes][k].to_i
        end
    end

    def get_data
        url = "https://services1.arcgis.com/0MSEUqKaxRlEPj5g/arcgis/rest/" +
              "services/ncov_cases/FeatureServer/1/query?f=json&" +
              "where=Confirmed>0&outFields=*"
        c = HTTPClient.new
        r = c.get url
        msg = JSON.parse r.body, symbolize_names: true
        raise "HTTP Error #{r.code}: #{r.body}" unless r.code == 200
        msg
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

class Covid < Plugin
    attr_accessor :covid

    def initialize
        super
        self.covid = CovidAPI.new
    end

    def help(plugin, topic="")
        "COVID-19 stats plugin"
    end

    def message(m)
    end

    def command(m, params)
        begin
            argv = parse params.fetch(:command, [])
            data = get_data argv
            m.reply make_message data, argv
        rescue => e
            m.reply "Failed: #{e.message}"
        end
    end

    def make_message data, argv
        region = data[:region] || 'Global'
        d = data[:data]
        if argv[:color]
            out = [
                "#{Bold}#{region}#{Bold}: ",
                "#{Bold}",
                "#{Irc.color(:olive)}",
                "#{d[0]}",
                "#{Irc.color}",
                " infected",
                "#{Bold}",
                " | ",
                "#{Bold}",
                "#{Irc.color(:red)}",
                "#{d[1]}",
                "#{Irc.color}",
                " dead (%.2f%%)" % (100.0 * d[1] / d[0]),
                "#{Bold}",
                " | ",
                "#{Bold}",
                "#{Irc.color(:limegreen)}",
                "#{d[2]}",
                "#{Irc.color}",
                " recovered",
                "#{Bold}",
                " | ",
                "#{Bold}",
                "Last update: #{format_time d[4]} ago",
                "#{Bold}",
            ].join
        else
            out = [
                "#{region}: ",
                "#{d[0]}",
                " infected",
                " | ",
                "#{d[1]}",
                " dead (%.2f%%)" % (100.0 * d[1] / d[0]),
                " | ",
                "#{d[2]}",
                " recovered",
                " | ",
                "Last update: #{format_time d[4]} ago",
            ].join
        end
    end

    def format_time ts
        diff = Time.now - Time.at(ts/1000)
        diff = diff.to_i
        if diff > 24 * 3600
            d = diff/86400
            h = diff/3600%24
            "#{d}d #{h}h"
        elsif diff > 3600
            h = diff/3600
            m = diff/60%60
            "#{h}h #{m}m"
        else
            m = diff/60
            s = diff%60
            "#{m}m #{s}s"
        end
    end

    def get_data argv
        if argv[:region] and argv[:region].size > 0
            self.covid.get_from_region argv[:region]
        else
            self.covid.get_global
        end
    end

    def parse argv
        ret = {
            region: nil,
            color: true,
        }
        op = OptionParser.new do |o|
            o.on('--[no-]color'){ |v| ret[:color] = v }
        end
        rest = op.parse argv
        ret[:region] = rest.join(' ').upcase
        ret
    end

    def help_msg
        "Usage: REGION [--[no-]color]"
    end

end

plugin = Covid.new

plugin.map 'covid *command', :action => :command
plugin.map 'covid', :action => :command

if __FILE__ == $0
    begin
        c = CovidAPI.new
        c.get_data[:features].each do |x|
            p x
        end
        # r = plugin.parse "--no-color".split
        # p r
        # p plugin.get_data r
        # p plugin.convert r
    rescue => e
        puts e
        puts e.backtrace
    end
end
