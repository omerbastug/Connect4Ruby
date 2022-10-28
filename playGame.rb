require_relative "game.rb"
require 'yaml'

# write hash out as a YAML file
#$gametoSave = { game: {row: nil, col: nil, startingturn: nil}, moves: Array.new }

# #if saved option chosen
# File.write('game.yml', $gametoSave.to_yaml)


# # load from file chosen
# from_file = YAML.load_file('game.yml')
# puts from_file[:moves].to_s
class PlayGame

    attr_accessor :game, :movesRed, :movesBlue

    def _initialize()
        @game =  nil
        @movesRed = Array.new()
        @movesBlue = Array.new()
    end

    def newGameView
        puts "Enter board dimensions (ROWxCOL format or skip for default)"
        dimensions = gets.chomp.strip
        dimensions = dimensions.to_s.split('x',-1)
        row = dimensions[0].to_i
        col = dimensions[1].to_i
        @game = Game.new(row,col) 
    end

    def loadFromFileView
        @movesRed =  Array.new 
        @movesBlue = Array.new
        puts "Enter name of the .yaml file"
        fn = gets.chomp 

        # load from file chosen
        begin
            from_file = YAML.load_file(fn+'.yml')
        rescue => exception
            puts "error"
            gets
            return false
        end
        @game = Game.new(
            from_file[:game][:row],
            from_file[:game][:col],
            from_file[:game][:startingturn])
        from_file[:moves].each do |move|
            begin
                #puts move.to_s
                @game.dropToken(move)
                if @game.turn.to_i == 0 then
                    @movesBlue.append(move+1)
                else 
                    @movesRed.append(move+1)
                end
            rescue => exception
                puts exception
                gets
                return false
            end
        end
        return true
    end

    def loadHistoryView
        games = $db.execute("SELECT * FROM games ORDER BY winner,game_id ASC LIMIT 5")
        
        while true
            #clear terminal
            puts "\e[H\e[2J"

            0.upto(games.length-1) do |i|
                puts i.to_s + " - " + games[i][6].to_s + "  id :" + games[i][0].to_s + "   " + (games[i][2] == nil ? "continue" : "replay")
            end

            puts ""
            puts "Enter 'back' to return to main menu"
            puts "Enter index: "
            input = gets.chomp
            
            if input=="back" then 
                return true
            else 
                begin
                    i = input.to_i
                    if (i < 0 || i > 4) then
                        raise "invalid digit"
                    end
                    replay = self.loadGame(games[i])
                    return replay
                rescue => exception
                    puts exception
                    gets
                end
            end
            
        end

    end

    def loadGame(game)
        replay = game[2] != nil
        @game = Game.new(game[4],game[5],game[3],game[0],game[2],replay)

        input = nil
        @movesRed =  Array.new 
        @movesBlue = Array.new

        moves = $db.execute("select  move_id, column from moves where game_id = ? order by move_id asc",[@game.id])

        moves.each_with_index do |move , i| 
            if replay then
                self.displayCurrent
                puts "0 - back"
                puts "1 - play from here"
                puts "next move"
                input = gets.chomp
                if input == "0" then
                    return
                elsif input == "1"
                    @game = Game.new(game[4],game[5],game[3])
                    redomoves = moves.slice(0,i)
                    redomoves.each do |rmove|
                        # reload move
                        begin
                            @game.dropToken(rmove[1])
                            if @game.turn.to_i == 0 then
                                @movesBlue.append(rmove[1]+1)
                            else 
                                @movesRed.append(rmove[1]+1)
                            end
                        rescue => exception
                            puts exception
                        end
                    end
                    return false
                end
            end

            # load move
            begin
                @game.dropToken(move[1],true)
                if @game.turn.to_i == 0 then
                    @movesBlue.append(move[1]+1)
                else 
                    @movesRed.append(move[1]+1)
                end
            rescue => exception
                puts exception
            end

            if !replay then
                
            end
        end
        return replay
    end

    def play()
        @movesRed = @movesRed==nil ? Array.new : @movesRed
        @movesBlue = @movesBlue==nil ? Array.new : @movesBlue
        while @game.winner == nil
            self.displayCurrent

            puts "Enter 'back' to return to main menu"
            puts "Enter 'save' to save game to file"
            puts "Enter column index to drop the token: "
            input = gets.chomp
            case input
            when "save"
                self.saveGametoyaml
            when "back"
                return
            else
                col = input.to_i - 1
                begin
                    @game.dropToken(col)
                    if @game.turn == 0 then
                        @movesBlue.append(col+1)
                    else 
                        @movesRed.append(col+1)
                    end
                rescue => exception
                    puts exception
                end
            end
            
        end

        puts "name for the match:"
        name = gets.chomp 
        $db.execute("update games set name = ? where game_id = ?",[name,@game.id])
    end
    def saveGametoyaml
        File.write('savedGame.yml', $gametoSavetoFile.to_yaml)
    end
    def displayCurrent
        #clear terminal
        puts "\e[H\e[2J"
        @game.display

        str = ""
        1.upto(@game.col) do |i|
            str += "  "+ i.to_s + "  "
        end
        puts str
        puts ""
        puts "Red : " + @movesRed.to_s
        puts "Blue : " + @movesBlue.to_s
        puts ""
    end
end

pg = PlayGame.new

while true
    lastgamegoing = $db.execute("select * from games where winner is null order by game_id desc limit 1")[0]
    hasLastGame = lastgamegoing != nil

    #clear terminal
    puts "\e[H\e[2J"
    puts "1 - New game"
    puts "2 - Load from history"
    puts "3 - Load from file"
    puts hasLastGame ? "4 - Continue last game" : ""
    puts ""
    puts "0 - Exit"
    puts "Enter digit: "
    input = gets.chomp.strip

    case input
    when "0"
        puts "Goodbye"
        break
    when "1"
        pg.newGameView
        pg.play
    when "2"
        replay = pg.loadHistoryView
        if !replay then
            pg.play()
        else
            gets
        end
    when "3"
        ok = pg.loadFromFileView
        if ok then 
            pg.play
        end
    when "4"
        if hasLastGame then 
            r = pg.loadGame(lastgamegoing)
            pg.play()
        else
            puts "nope"
        end
        
    else
       puts "Error: input invalid (#{input})"
    end
    
end


# pg = PlayGame.new
# pg.start
# puts pg.game.display