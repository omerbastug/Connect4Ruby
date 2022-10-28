require "colorize"

require_relative "winChecks.rb"
include WinCheck

require_relative "DB.rb"
include DB
$db = DB.getDatabase
$gametoSavetoFile = { :game => {:row => nil, :col => nil, :startingturn => nil}, :moves => Array.new }

class Game
    attr_accessor :id, :row, :col, :name,:turn, :winner, :matrix, :lastmove, :replay
    BLUE = 1;
    RED = 0;
    def initialize(row = 6, col = 7,turn = nil, id = nil, win = nil,replay = false)
        if row<6 or col<7 or (col-row)>2 then
            row = 6
            col = 7
            puts "Default dimensions 6x7"
        end

        @matrix = Array.new(row){Array.new(col){nil}}
        @row = row
        @col = col
        @turn = turn || rand(RED..BLUE)
        @id = id
        @replay = replay

        if @id != nil then
            return
        end

        # save to db
        $db.execute("INSERT INTO games (turn, startingturn, row_count, column_count)
                    VALUES (?, ?, ?, ?)", [@turn, @turn, @row, @col])
        @id = $db.last_insert_row_id
        
        $gametoSavetoFile[:game][:row] = @row
        $gametoSavetoFile[:game][:col] = @col
        $gametoSavetoFile[:game][:startingturn] = @turn
    end
    
    def changeTurn
        @turn = (@turn.to_i + 1) % 2
        $db.execute("UPDATE games SET turn = ? WHERE game_id = ?", [@turn,@id])
    end

    def display 
        puts @turn == BLUE ? "Blue's turn" : "Red's turn"
        str = ""
        0.upto(@row-1) do |i|
            str += "|"
            0.upto(@col-1) do |j|
                circle = @matrix[i][j] == nil ? "⬤".light_black : (@matrix[i][j] == BLUE ? "⬤".blue : "⬤".red)
                str += " " + circle + "  |"
            end
            str += "\n"
        end
        str += "‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"
        puts str
    end

    def dropToken(col, load = false)
        if @winner != nil and !@replay then
            raise "Game ended"
        end
        if @matrix[0][col.to_i] != nil then
            raise "Column full"
        end
        if col > @col - 1 || col < 0 then
            raise "Invalid column"
        end
        i = 0;
        while i<@row-1 and matrix[i+1][col.to_i] == nil
            i+= 1
        end
        matrix[i][col.to_i] = @turn;

        if load then
            self.checkWin(i,col)
            self.changeTurn
            return
        end

        # ADD MOVE TO DATABASE
        $db.execute("INSERT INTO moves (game_id, parentNode, column, color)
        VALUES (?, ?, ?, ?)", [@id, @lastmove, col, @turn])
        @lastmove = $db.last_insert_row_id
        $gametoSavetoFile[:moves].append(col)

        # CHECK WIN
        self.checkWin(i,col)
        self.changeTurn

    end

    def checkWin(i,j)
        vwin = WinCheck.vertical(self.matrix,i,j)
        if vwin != nil then
            @winner = @turn
            @replay ? "" : $db.execute("UPDATE games SET winner = ? WHERE game_id = ?", [@winner,@id])
            self.gameWinDisplay(vwin)
            return
        end
        hwin = WinCheck.horizontal(self.matrix,i,j)
        if hwin != nil then
            @winner = @turn
            @replay ? "" : $db.execute("UPDATE games SET winner = ? WHERE game_id = ?", [@winner,@id])
            self.gameWinDisplay(hwin)
            return
        end
        duwin = WinCheck.diagonalUp(self.matrix,i,j)
        if duwin != nil then
            @winner = @turn
            @replay ? "" : $db.execute("UPDATE games SET winner = ? WHERE game_id = ?", [@winner,@id])
            self.gameWinDisplay(duwin)
            return
        end
        ddwin = WinCheck.diagonalDown(self.matrix,i,j)
        if ddwin != nil then
            @winner = @turn
            @replay ? "" : $db.execute("UPDATE games SET winner = ? WHERE game_id = ?", [@winner,@id])
            self.gameWinDisplay(ddwin)
            return
        end
    end

    def gameWinDisplay(hash)
        x = hash[:i]
        y = hash[:j]
        direction = hash[:direction]

        case direction
            when "h"
                0.upto(3) do |i|
                    @matrix[x][y+i] = "winner"
                end
            when "v"
                0.upto(3) do |i|
                    @matrix[x+i][y] = "winner"
                end
            when "du"
                0.upto(3) do |i|
                    @matrix[x-i][y+i] = "winner"
                end
            when "dd"
                0.upto(3) do |i|
                    @matrix[x+i][y+i] = "winner"
                end
            else
        end
        str = ""
        0.upto(@row-1) do |i|
            str += "|"
            0.upto(@col-1) do |j|
                circle = @matrix[i][j] == nil ? "⬤".light_black : (@matrix[i][j] == "winner" ? "⬤".green : (@matrix[i][j] == BLUE ? "⬤".blue : "⬤".red))
                str += " " + circle + "  |"
            end
            str += "\n"
        end
        str += "‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"
        #clear terminal
        puts "\e[H\e[2J"
        puts @winner == BLUE ? "         BLUE WON" : "RED WON"
        puts str
    end

    def setName(name)
        $db.execute("UPDATE games SET name = ? WHERE game_id = ?", [@name,@id])
    end
end

# currentGame = Game.new()

# puts currentGame.id

# 2.upto(3) do |i|
#     begin
#         currentGame.dropToken(i)
#         currentGame.dropToken(i)
#         currentGame.display
#     rescue => exception
#         puts exception
#         currentGame.display
#     end
# end

# $db.execute("SELECT  * from games where winner is null order by ")
