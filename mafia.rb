require 'thread'

Messages = {
  :mafiaEng => {
    :mafia => "#{Irc.color(:red)}#{Bold}Mafioso#{Bold}#{Color}",
    :detective => "#{Irc.color(:teal)}#{Bold}Sherlock#{Bold}#{Color}",
    :doctor => "#{Irc.color(:orange)}#{Bold}Medic#{Bold}#{Color}",
    :normal => "#{Bold}Regular guy#{Bold}",
    :initGame => "#{Irc.color(:red)}#{Bold}Mafia#{Bold}#{Color} game in %{channel} "\
                 "will begin in #{Irc.color(:red)}%{seconds}#{Color} seconds.",
    :initGameSuccess => "#{Irc.color(:red)}#{Bold}Mafia#{Bold}#{Color} begins.",
    :initGameFailure => "#{Irc.color(:red)}#{Bold}Mafia#{Bold}#{Color} didn\'t begin, not enough players :(",
    :addPlayerSuccess => "#{Irc.color(:green)}#{Bold}%{player}#{Bold}#{Color} joined the game",
    :addPlayerFailue => "Too late, game has already started",
    :addPlayerAlreadyInGame => "You're already in the game, %{player}!",
    # :initUserNormal => "You are a normal member of the society. Your goal is to reveal all the "\
    #                    "mafiosos in the city. You can vote on 1 player each day. Player with "\
    #                    "highest vote count will be removed.",
    # :initUserDetective => "You are a Sherlock. Your goal is to reveal all the mafiosos in the city. "\
    #                       "You can vote on 1 player each day. Player with highest vote count will be "\
    #                       "removed. Additionally, during night you can check if given player is a "\
    #                       "mafioso and then, during the day, convice the rest of the city to kill him.",
    # :initUserMafia => "You are a mafioso. Your job is to kill all the normal citizens. You can vote "\
    #                   "on a given player during the night, when you will also meet other members of "\
    #                   "the Mafia. Additionally, you can vote during the day like a normal member of society.",
    # :turnDay => 'It\'s a day now. Villagers should vote who should be lynched.',
    # :turnNight => 'It\'s the night. Villagers, beware!',

    :initUser => "Your role: %{role}.",
    :initUserMafia => "Mafia members: %{mafiamembers}",

    # :turnDay => "",
    :turnDay => "It's #{Irc.color(:yellow)}#{Bold}DAYTIME!#{Bold}#{Color}. You have "\
                "#{Irc.color(:yellow)}%{seconds}#{Color} seconds to talk about it",
    :turnDayVote => "It\'s time to vote. You have #{Irc.color(:yellow)}%{seconds}#{Color} seconds to vote.",
    :turnNight => "It's #{Irc.color(:navyblue)}#{Bold}NIGHTTIME!#{Bold}#{Color}!"\
                  "You have #{Irc.color(:navyblue)}%{seconds}#{Color} seconds to vote.\n"\
                  "#{Irc.color(:teal)}#{Bold}Sherlocks#{Bold}#{Color}: type "\
                  "#{Irc.color(:teal)}/msg %{bot} check nickname#{Color} to sherlock\n"\
                  "#{Irc.color(:orange)}#{Bold}Medics#{Bold}#{Color}: type "\
                  "#{Irc.color(:orange)}/msg %{bot} protect nickname#{Color} to protect them\n"\
                  "#{Irc.color(:red)}#{Bold}Mafiosi#{Bold}#{Color}: type "\
                  "#{Irc.color(:red)}/msg %{bot} kill nickname#{Color} to vote to kill",

    :votedLynch => "#{Irc.color(:brown)}%{player}#{Color} voted to lynch #{Irc.color(:brown)}%{suspect}#{Color}",
    :votedKill => "%{player} voted to kill %{victim}",
    # :lynchMafia => "%{player}, the WOLF, dies!",
    # :lynchDetective => "%{player} dies, retards",
    # :lynchNormal => "%{player} dies. Unfortunately, you discover no evidence that they were the wolf",
    :lynch => "%{player} (%{role}) is lynched!",
    :lynchNoWinner => "Since you can't decide, nobody is chosen.",
    :lynchNone => "Nobody dies.",

    :mafiaKill => "%{player} (%{role}) has been killed by the mafia!",
    :mafiaKillNone => "Mafia members are known to be retarded. They failed to kill anyone.",
    # :voteKill => ''

    :detectiveCheck => "You sherlock that %{player} is a %{role}.",

    :doctorSaved => "%{player} was left beaten in a dumpster by the local mafia members, "\
                    "but a dumpster-diving %{doctor} managed to find and heal them.",

    :mafiaWin => "Mafia wins!",
    :mafiaLose => "Mafia loses!"
    
  },
  :weregameEng => {
    :mafia => "#{Irc.color(:red)}#{Bold}Werewolf#{Bold}#{Color}",
    :detective => "#{Irc.color(:teal)}#{Bold}Seer#{Bold}#{Color}",
    :doctor => "#{Irc.color(:orange)}#{Bold}Medic#{Bold}#{Color}",
    :normal => "#{Bold}Villager#{Bold}",
    :initGame => "#{Irc.color(:red)}#{Bold}Weregame#{Bold}#{Color} in %{channel} "\
                 "will begin in #{Irc.color(:red)}%{seconds}#{Color} seconds.",
    :initGameSuccess => "#{Irc.color(:red)}#{Bold}Weregame#{Bold}#{Color} begins.",
    :initGameFailure => "#{Irc.color(:red)}#{Bold}Weregame#{Bold}#{Color} didn\'t begin, not enough players :(",
    :addPlayerSuccess => "#{Irc.color(:green)}#{Bold}%{player}#{Bold}#{Color} joined the game",
    :addPlayerFailue => "Too late, game has already started",
    :addPlayerAlreadyInGame => "You're already in the game, %{player}!",
    # :initUserNormal => "You are a normal member of the society.",
    # :initUserDetective => "You are the seer.",
    # :initUserMafia => "You are the werewolf.",
    # :turnDay => 'It\'s a day now. Villagers should vote who should be lynched.',
    # :turnNight => 'It\'s the night. Villagers, beware!',

    :initUser => "Your role: %{role}.",
    :initUserMafia => "As a werewolf, you know others: %{mafiamembers}",


    :turnDay => "It's #{Irc.color(:yellow)}#{Bold}DAYTIME!#{Bold}#{Color}. You have "\
                "#{Irc.color(:yellow)}%{seconds}#{Color} seconds to talk about it",
    :turnDayVote => "It\'s time to vote. You have #{Irc.color(:yellow)}%{seconds}#{Color} seconds to vote.",
    :turnNight => "It's #{Irc.color(:navyblue)}#{Bold}NIGHTTIME!#{Bold}#{Color}!"\
                  "You have #{Irc.color(:navyblue)}%{seconds}#{Color} seconds to vote.\n"\
                  "#{Irc.color(:teal)}#{Bold}Seers#{Bold}#{Color}: type "\
                  "#{Irc.color(:teal)}/msg %{bot} check nickname#{Color} to sherlock\n"\
                  "#{Irc.color(:orange)}#{Bold}Medics#{Bold}#{Color}: type "\
                  "#{Irc.color(:orange)}/msg %{bot} protect nickname#{Color} to protect them\n"\
                  "#{Irc.color(:red)}#{Bold}Wolves#{Bold}#{Color}: type "\
                  "#{Irc.color(:red)}/msg %{bot} kill nickname#{Color} to vote to kill",
                  # "Wolves, type /msg %{bot} kill <player> to cast a vote to kill that player\n"\
                  # "Seers, type /msg %{bot} check <player> to see their occupation\n"\

    :votedLynch => "#{Irc.color(:brown)}%{player}#{Color} voted to lynch #{Irc.color(:brown)}%{suspect}#{Color}",
    # :votedLynch => "%{player} voted to kill %{suspect}",
    :votedKill => "%{player} voted to kill %{victim}",
    # :lynchMafia => "%{player}, the WOLF, dies!",
    # :lynchDetective => "%{player} dies, retards",
    # :lynchNormal => "%{player} dies. Unfortunately, you discover no evidence that they were the wolf",
    :lynch => "%{player} (%{role}) is lynched!",
    :lynchNoWinner => "Since you can't decide, nobody is chosen.",
    :lynchNone => "Nobody dies.",

    :mafiaKill => "%{player} (%{role}) has been killed by the wolf!",
    :mafiaKillNone => "Werewolves are known to be retarded. They failed to kill anyone.",
    # :voteKill => ''

    :detectiveCheck => "The cards tell you that %{player} is a %{role}",

    :doctorSaved => "%{player} was left beaten in a dumpster by the local wolves, "\
                    "but a dumpster-diving %{doctor} managed to find and heal them.",

    :mafiaWin => "Werewolves win!",
    :mafiaLose => "Villagers win!"

  },
  :voldemortEng => {
    :mafia => "#{Irc.color(:red)}#{Bold}Death Eater#{Bold}#{Color}",
    :detective => "#{Irc.color(:teal)}#{Bold}Harry Potter#{Bold}#{Color}",
    :doctor => "#{Irc.color(:purple)}#{Bold}Dumbledore#{Bold}#{Color}",
    :normal => "#{Bold}Auror#{Bold}",

    :initGame => "#{Irc.color(:red)}#{Bold}Death Eater#{Bold}#{Color} game in %{channel} will begin in #{Irc.color(:red)}%{seconds}#{Color} seconds.",
    :initGameSuccess => "#{Irc.color(:red)}#{Bold}Death Eater#{Bold}#{Color} begins.",
    :initGameFailure => "#{Irc.color(:red)}#{Bold}Death Eater#{Bold}#{Color} didn\'t begin, not enough players :(",

    :addPlayerSuccess => "#{Irc.color(:green)}#{Bold}%{player}#{Bold}#{Color} joined the game",
    :addPlayerFailue => "Too late, game has already started",
    :addPlayerAlreadyInGame => "You're already in the game, %{player}!",

    :initUser => "Your role: %{role}.",
    :initUserMafia => "Death Eaters: %{mafiamembers}",

    :turnDay => "It's #{Irc.color(:yellow)}#{Bold}DAYTIME!#{Bold}#{Color}. You have #{Irc.color(:yellow)}%{seconds}#{Color} seconds to talk about it",
    :turnDayVote => "It\'s time to vote. You have #{Irc.color(:yellow)}%{seconds}#{Color} seconds to vote.",
    :turnNight => "It's #{Irc.color(:navyblue)}#{Bold}NIGHTTIME!#{Bold}#{Color}! You have #{Irc.color(:navyblue)}%{seconds}#{Color} seconds to vote.\n"\
                  "#{Irc.color(:teal)}#{Bold}Harry Potters#{Bold}#{Color}: type #{Irc.color(:teal)}/msg %{bot} check nickname#{Color} to use your death eater radar on him\n"\
                  "#{Irc.color(:purple)}#{Bold}Dumbledores#{Bold}#{Color}: type #{Irc.color(:purple)}/msg %{bot} protect nickname#{Color} to protect\n"\
                  "#{Irc.color(:red)}#{Bold}Death Eaters#{Bold}#{Color}: type #{Irc.color(:red)}/msg %{bot} kill nickname#{Color} to vote to kill",

    :votedLynch => "#{Irc.color(:teal)}%{player}#{Color} voted to arrest #{Irc.color(:yellow)}%{suspect}#{Color}",
    :votedKill => "%{player} voted to kill %{victim}",

    :lynch => "%{player} (%{role}) is sent to Azkaban!",
    :lynchNoWinner => "Since you can't decide, nobody is chosen.",
    :lynchNone => "Nobody dies.",

    :mafiaKill => "%{player} (%{role}) has been killed by the Death Eaters!",
    :mafiaKillNone => "Death Eaters are known to be retarded. They failed to kill anyone.",

    :detectiveCheck => "You use your manstincts to find that %{player} is a %{role}",
    :doctorSaved => "You duel with death eaters to protect %{player}",

    :mafiaWin => "Voldemort wins!",
    :mafiaLose => "Voldemort loses!"
  }
}

Timers = {
  :gameStart => 120,
  :dayDiscussion => 60,
  :dayVote => 90,
  :nightVote => 60,
  :betweenTurns => 3
}


MinimumPlayers = 5

class MafiaGame
  attr_accessor :bot
  attr_accessor :channel
  attr_accessor :exit
  attr_accessor :players
  attr_accessor :plugin
  attr_accessor :startTime
  attr_accessor :sync
  attr_accessor :texts

  def mafiosiPerPlayers(players)
    (players.to_i)/3
  end

  def detectivesPerPlayers(players)
    # rand(players/2)+1
    (players.to_i)/8+1
  end

  def doctorsPerPlayers(players)
    # (players.to_i)/8+1
    (players.to_i)/10+1
  end

  def initialize(bot, plugin, channel, texts)
    @bot = bot
    @channel = channel.to_s
    @plugin = plugin
    @sync = Mutex.new
    @texts = texts

    @started = false

    @turn = 1
    @turnType = nil
    @exit = false

    @players = []

    @playersInit = []

    @vote = nil

    @startTime = Time.now + Timers[:gameStart]

    Thread.new {

      begin
        srand (Time.now.to_f * 1000).to_i

        msg @texts[:initGame] % {
          :channel => @channel,
          :seconds => Timers[:gameStart]
        }


        while @sync.synchronize{ Time.now < @startTime } do
          sleep(0.05)
        end
        

        @sync.synchronize {
          
          if @playersInit.size < MinimumPlayers
            msg @texts[:initGameFailure]
            @plugin.clearGame
            next
          end

          @started = true

          msg @texts[:initGameSuccess]

          @playersInit.shuffle!

          numberOfMafiaMembers = mafiosiPerPlayers @playersInit.size
          detectives = detectivesPerPlayers @playersInit.size
          doctors = doctorsPerPlayers @playersInit.size

          players = {}

          mafiamembers = []

          numberOfMafiaMembers.times {
            p = @playersInit.pop
            players[p.nick.downcase] = {
              :player => p,
              :role => :mafia
            }
            mafiamembers.push p.nick
          }

          detectives.times {
            p = @playersInit.pop
            next if p == nil
            players[p.nick.downcase] = {
              :player => p,
              :role => :detective
            }
          }

          doctors.times {
            p = @playersInit.pop
            next if p == nil
            players[p.nick.downcase] = {
              :player => p,
              :role => :doctor
            }
          }

          @playersInit.each { |p|
            players[p.nick.downcase] = {
              :player => p,
              :role => :normal
            }
          }

          @players = players

          # mafiamembers = mafiamembers.map{ |n| "#{Irc.color(:green)}#{n}#{Color}" }.join(' | ')
          mafiamembers = prettyStringPlayers mafiamembers

          @players.each { |k,v|

            m = @texts[:initUser] % { :role => @texts[v[:role]] }

            puts "#{v[:player].nick} => #{m}"
            notice v[:player].nick, m
            
            notice v[:player].nick, @texts[:initUserMafia] % { :mafiamembers => mafiamembers } if v[:role] == :mafia
          }

          @turn = 1

        }

        newTurn
      rescue Exception => e
        msg "Exception: #{e.message}"
        e.backtrace.each { |l|
          puts "Backtrace: #{l}"
        }
      end

    }

  end
  
  def addPlayer(p)
    # msg "trying to join #{p.inspect}"
    @sync.synchronize {

      if @playersInit.find{|v| p.nick.downcase == v.nick.downcase }
        msg @texts[:addPlayerAlreadyInGame] % {
          :player => p.nick
        }
        return false
      end

      if @started
        msg @texts[:addPlayerFailue]
        return false 
      end

      pdata = Object.new
      class << pdata
        attr_accessor :nick
      end
      pdata.nick = p.nick.to_s

      @playersInit.push pdata
      msg @texts[:addPlayerSuccess] % {
        :player => p.nick
      }
    }
    return true
  end

  def killPlayer(p,txt)
    nick = p[:player].nick
    msg txt % {
      :player => nick,
      :role => @texts[p[:role]]
    }
    @players.delete nick.downcase
  end

  def msg(s)
    @bot.say @channel, s
  end

  def priv(p,s)
    @bot.say p, s
  end

  def notice(p,s)
    @bot.notice p, s
  end

  def newTurn

    begin
      turn = nil
      done = nil

      @sync.synchronize {
        turn = (@turn & 1) == 1 ? :day : :night
        mafiaSize = @players.count{|k,v| v[:role] == :mafia}
        totalSize = @players.size
        done = ((mafiaSize + 1 == totalSize) or (mafiaSize == 0))
        # msg "Mafia: #{mafiaSize}, total: #{totalSize}, done: #{done}"
        @turnType = turn
        exit = @exit
      }

      return if exit

      # msg "Turn: #{turn.to_s}, Done: #{done}"

      l = []
      @sync.synchronize { l = playersList }

      # ps = l.map{|v| "#{Irc.color(:green)}#{v}#{Color}" }.join(' | ')

      lStr = prettyStringPlayers l
      
      msg "#{Bold}#{Irc.color(:red)}New turn!#{Color}#{Bold} %{count} still in the game: %{ps}" % {
        :count => l.size,
        :ps => lStr
      }

    rescue Exception => e
      msg "Exception #{e.message}"
    end

    Thread.new {
      begin
        if done
          endOfGame
        elsif turn == :day
          doDay
        else
          doNight
        end
      rescue Exception => e
        msg "Exception: #{e.message}"
        e.backtrace.each { |l|
          puts "Backtrace: #{l}"
        }
      end
    }
  end

  def doDay
    @sync.synchronize {
      @vote = nil
    }

    msg @texts[:turnDay] % {
      :bot => @bot.nick,
      :seconds => Timers[:dayDiscussion]
    }

    sleep(Timers[:dayDiscussion])

    @sync.synchronize {
      @vote = {
        :votes => {},
        :voters => []
      }
      @players.each {|k,v|
        @vote[:voters].push v[:player].nick.downcase
      }
    }

    msg @texts[:turnDayVote] % {
      :bot => @bot.nick,
      :seconds => Timers[:dayVote]
    }

    # sleep(Timers[:dayVote])
    waitForVotes Timers[:dayVote]

    @sync.synchronize {
      dead = nil
      max = @vote[:votes].max_by{|k,v| v}
      dead = @vote[:votes].select{|k,v| v == max[1]}

      # msg "Player to die: #{dead.inspect}" if dead != nil

      puts max.inspect
      puts dead.inspect
      puts @vote[:votes].inspect
      puts @vote[:voters].inspect

      if max == nil
        msg @texts[:lynchNone]
      elsif dead.size == 1
          
        player = @players.find{ |k,v| v[:player].nick.downcase == dead[0][0].downcase }
       
        # msg "Player to die: #{player.inspect}"

        killPlayer player[1], @texts[:lynch]
      else
        msg @texts[:lynchNoWinner]
      end

      @vote = nil
      @turn = @turn.next
    }

    sleep(Timers[:betweenTurns])
    newTurn
   end

  def doNight
    msg @texts[:turnNight] % {
      :bot => @bot.nick,
      :seconds => Timers[:nightVote]
    }

    @sync.synchronize {
      @vote = {
        :votes => {},
        :voters => []
      }
      @checks = {}
      @saves = {}
      @players.each {|k,v|
        @vote[:voters].push v[:player].nick.downcase if v[:role] == :mafia
      }
    }

    # waitForVotes Timers[:nightVote]
    sleep Timers[:nightVote]


    @sync.synchronize {
      dead = @vote[:votes].max_by{|k,v| v}

      handleChecks = lambda { |dead|
        @checks.each { |k,v|
          found = @players.find{ |i,j| v[:player].nick.downcase == i.downcase }
          next if found == nil
          next if dead.downcase == k
          notice k, @texts[:detectiveCheck] % {
            :player => v[:player].nick,
            :role => @texts[v[:role]]
          }
        }
      }

      if dead != nil
        player = @players.find{ |k,v| v[:player].nick.downcase == dead[0].downcase }

        saved = @saves.find{|k,v| k.downcase == player[0].downcase }

        handleChecks.call saved ? '' : player[1][:player].nick.downcase

        if saved != nil
          msg @texts[:doctorSaved] % {
            :player => player[1][:player].nick,
            :doctor => @texts[:doctor]
          }
        else
          killPlayer player[1], @texts[:mafiaKill]
        end

      else
        handleChecks.call ''
        msg @texts[:mafiaKillNone]
      end




      @checks = {}

      @vote = nil

      @turn = @turn.next
    }
    
    sleep(Timers[:betweenTurns])
    newTurn
  end

  def endOfGame
    @sync.synchronize {
      mafiaSize = @players.count{|k,v| v[:role] == :mafia}
      totalSize = @players.size
      # msg "End of game. Mafia: #{mafiaSize}"

      winner = ((totalSize - mafiaSize <= 1) and mafiaSize) ? :mafia : :normal

      m = winner != :normal ? @texts[:mafiaWin] : @texts[:mafiaLose]

      team = []
      @players.each{ |k,v|
        isWinner = v[:role] == :mafia
        isWinner = !isWinner if winner != :mafia
        team.push v[:player].nick if isWinner
      }

      if winner == :mafia
        player = @players.find{ |k,v| v[:role] != :mafia }
        killPlayer player[1], @texts[:mafiaKill]
      end

      changed = team.map{|v| "#{Irc.color(:green)}#{v}#{Color}" }

      msg m
      msg "Congratulations #{changed.join(' | ')}!"
    }
    @plugin.clearGame
  end

  def checkPlayer(checker, checkee)
    @sync.synchronize {
      p = @players[checker.nick.downcase]
      role = p[:role] if p != nil

      turn = (@turn & 1) == 1 ? :day : :night

      if(role != :detective or turn != :night)
        notice checker.nick, "You dirty cheater!"
        return
      end

      result = @players.find{ |k,v| v[:player].nick.downcase == checkee.downcase }

      if result == nil
        notice checker.nick, "No such player"
        return
      end

      notice checker.nick, "You'll be notified at the end of the turn"
      @checks[checker.nick.downcase] = result[1]
    }
  end

  def savePlayer(saver, savee)
    saveeCanonical = savee.downcase
    @sync.synchronize {
      p = @players[saver.nick.downcase]
      role = p[:role] if p != nil

      turn = (@turn & 1) == 1 ? :day : :night

      if(role != :doctor or turn != :night)
        notice saver.nick, "You dirty cheater!"
        return
      end

      result = @players.find{ |k,v| v[:player].nick.downcase == saveeCanonical }

      if result == nil
        notice saver.nick, "No such player"
        return
      end

      notice saver.nick, "Ok"
      @saves[saveeCanonical] = 1 + ((@saves.has_key? saveeCanonical) ? @saves[saveeCanonical] : 0)
    }
  end

  def vote(m, kilee)
    kileeCanonical = kilee.downcase
    @sync.synchronize {
      # msg "Vote registered from #{m.source.nick} for #{kilee}"

      if(@turnType == nil)
        m.reply "%{nick}: the game hasn't started yet, retard" % {
          :nick => m.source.nick
        }
        return
      end

      if(@vote == nil)
        m.reply "%{nick}: you can't vote now, retard" % {
          :nick => m.source.nick
        }
        return
      end

      if (@vote[:voters].include? m.source.nick.downcase) == false
        m.reply "%{nick}: you either have voted already or aren't in the game, retard" % {
          :nick => m.source.nick
        }
        return
      end

      result = @players.find{ |k,v| v[:player].nick.downcase == kileeCanonical }

      if result == nil
        m.reply "#{m.source.nick}: No such player '#{kilee}'"
        return
      end

      if m.channel and @turnType == :day
        m.reply @texts[:votedLynch] % {
          :player => m.source.nick,
          :suspect => kilee
        }
      elsif m.channel.to_s.size == 0 and @turnType == :night
        # msg @texts[:votedKill] % {
        notice m.source.nick, @texts[:votedKill] % {
          :player => m.source.nick,
          :victim => kilee
        }
      else
        m.reply "%{nick}: wrong turn type, retard" % {
          :nick => m.source.nick
        }
        return 
      end
      @vote[:votes][kileeCanonical] = 1 + ((@vote[:votes].has_key? kileeCanonical) ? @vote[:votes][kileeCanonical] : 0)
      @vote[:voters].delete m.source.nick.downcase
      printVotes if(m.channel)
    }
  end

  def printVotes
    l = []
    @vote[:votes].each { |k,v|
       tmp = { :nick => k, :votes => v }
       l.push tmp
    }

    l.sort!{|x,y| x[:votes] <=> y[:votes]}


    votes = l.map { |v|
      "#{Bold}#{v[:nick]}#{Bold}: #{Bold}#{v[:votes]}#{Bold}"
    }.join(' | ')

    msg "Current votes: #{votes}"
  end

  def prettyStringPlayers(l)
      return l.map{|v| "#{Irc.color(:green)}#{v}#{Color}" }.join(' | ')
  end

  def playersList 
    ps = []
    @players.each { |k,v|
      ps.push v[:player].nick
    }
    return ps.sort_by{ |n| n.downcase }
  end

  def checkIfVotesDecisive
    @sync.synchronize {
      return false if @vote == nil

      max = @vote[:votes].max_by{|k,v| v}

      return false if max == nil

      left = @vote[:voters].size

      # puts "Max: #{max.inspect}, left: #{left.inspect}, votes: #{@vote[:votes].inspect}"

      return false if left >= max[1]

      @vote[:votes].each { |k,v|
        return false if (v + left >= max[1]) and (k != max[0])
      }
      return true
    }
  end

  def waitForVotes(t, step = 0.05)
    finish = Time.now

    check = lambda { 
      diff = Time.now - finish - t 
      voters = @sync.synchronize { @vote[:voters].size }
      notEmpty = voters > 0
      # puts "Diff: #{diff}, voters !empty: #{notEmpty}, voters: #{voters.inspect}"
      return false if diff > 0
      decisive = checkIfVotesDecisive
      # puts "decisive: #{decisive}"
      return false if decisive
      return notEmpty
    }

    # puts "Final: #{final}, @voters: #{@sync.synchronize { @vote[:voters].size > 0}}"
    # while ((final < ((Time.new.to_f*1000).to_i)) and (@sync.synchronize { @vote[:voters].size > 0})) do
    # while ((Time.now - finish < t.to_f) and (@sync.synchronize { @vote[:voters].size > 0})) do
      # elapsed = (Time.new.to_f*1000).to_i
      # puts "Elapsed: #{elapsed}"
    while check.call do
      sleep(step)      
    end
  end

end

class MafiaPlugin < Plugin

  def initialize
    super
    @registry.set_default(Array.new)

    @game = nil

    @sync = Mutex.new
  end

  def help(plugin, topic="")
    "MafiaPlugin"
  end

  def message(m)
    begin

      # puts "channel: #{m.channel.to_s}, msg: #{m.message}"

      @sync.synchronize {
        # puts "msg: #{m.message}, channel: #{m.channel.to_s} game: #{@game.channel}"
        # puts @game.inspect
        return if @game == nil
        return if m.channel.to_s.size > 0 and @game.sync.synchronize { m.channel.to_s != @game.channel }

        # m.reply "Good channel, game exists, m.message: #{m.message}"

        case m.message
        when /^jo$/i
          @game.addPlayer m.source
        when /^kill ([A-Za-z0-9\-\_\^\[\]\\]+)$/i
          @game.vote m, $1 if m.channel.to_s.size == 0
        when /^vote ([A-Za-z0-9\-\_\^\[\]\\]+)$/i
          @game.vote m, $1 if m.channel.to_s.size > 0
        when /^check ([A-Za-z0-9\-\_\^\[\]\\]+)$/i
          @game.checkPlayer m.source, $1 if m.channel.to_s.size == 0
        when /^protect ([A-Za-z0-9\-\_\^\[\]\\]+)$/i
          @game.savePlayer m.source, $1 if m.channel.to_s.size == 0
        end
      }
    rescue Exception => e
      m.reply "Exception: #{e.message}"
      e.backtrace.each { |l|
        puts "Backtrace: #{l}"
      }
    end
  end

  def clearGame
    @sync.synchronize {
      if @game != nil
        @game.bot = nil
        @game = nil
      end
    }
  end

  def startGame(m, texts)
    return if m.channel.to_s.size < 1
    @sync.synchronize{ 
      return false if @game != nil
      @game = MafiaGame.new(@bot,self,m.channel.to_s,texts)
      @game.addPlayer m.source
      return true
    }

    # Thread.new {
    #   @sync.synchronize{
    #     sleep(1)
    #     @game.addPlayer m.source unless @game == nil
    #   }
    # }

  end

  def mafia(m, p)
    m.reply "Already playing a game!" unless startGame(m, Messages[:mafiaEng])
  end

  def weregame(m, p)
    m.reply "Already playing a game!" unless startGame(m, Messages[:weregameEng])
  end

  def hptest(m, p)
    m.reply "Already playing a game!" unless startGame(m, Messages[:voldemortEng])
  end

  def stopGame(m,p)
    clearGame
    m.reply "done"
  end

  def listPlayers(m, p)
    players = []
    @sync.synchronize{
      return if @game == nil

      @game.sync.synchronize{

        players = @game.prettyStringPlayers @game.playersList
      }
    }
    m.reply "Still playing: #{players}"
  end

  def forceStart(m, p)
    @sync.synchronize{
      if(@game == nil)
        m.reply "No game to start :("
        return  
      end

      @game.sync.synchronize {
        @game.startTime = Time.now
      }

    }
  end

end


plugin = MafiaPlugin.new

plugin.map "mafia", :action => :mafia
plugin.map "weregame", :action => :weregame
plugin.map "voldemort", :action => :hptest
plugin.map "mafia force start", :action => :forceStart
plugin.map "mafia stop", :action => :stopGame, :auth_path => 'manage'
plugin.map "mafia list", :action => :listPlayers

plugin.default_auth('manage', false)