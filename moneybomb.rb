require 'gosu'

module ZOrder
    BACKGROUND, CASH, PLAYER, UI = *0..3
end

class Player 
    attr_reader :score, :nomorelifes
    def initialize
        @image = Gosu::Image.new("media/tyler.png")
        @chaching = Gosu::Sample.new("media/chaching.wav")
        @boom = Gosu::Sample.new("media/boom.wav")
        @x = @vel_x = 0
        @y = 410
        @score = 0
        @attempt = 1
        @nomorelifes = false
    end
    def warp(x)
        @x = x 
    end
    def turn_left
        @angle = 90
        @angle += 180
    end
    def turn_right
        @angle = -90
        @angle += -180
    end
    def accelerate
        @vel_x += 0.5
    end
    def move_left 
        @x -= @vel_x
        @x %= 640

        @vel_x *= 0.95
    end
    def move_right
        @x += @vel_x
        @x %= 640
        @vel_x *= 0.95
    end
    def score
        @score
    end
    def collect_cash(cashes)
        cashes.reject! do |cash|
            if Gosu.distance(@x, @y, cash.x, cash.y) < 35
                @score += 1
                @chaching.play 
                true 
            elsif cash.y > 480
                true
            else 
                false
            end
        end
    end
    def collect_largecash(large_cashes)
        large_cashes.reject! do |large_cash|
            if Gosu.distance(@x, @y, large_cash.x, large_cash.y) < 35
                @score += 10
                @chaching.play 
                true
            elsif large_cash.y > 480
                true
            else
                false
            end
        end
    end
    def hit_bombs(bombs)
        bombs.reject! do |bomb|
            if Gosu.distance(@x, @y, bomb.x, bomb.y) < 35
                @nomorelifes = true
                @boom.play
                true
            elsif bomb.y > 480
                true
            else
                false
            end
        end
    end
    def hit_spacebar
        @nomorelifes = false
        @score = 0
        @attempt += 1
    end
    def attempt
        @attempt
    end
    def draw
        @image.draw(@x, @y, ZOrder::PLAYER)
    end
end

class Cash 
    attr_reader :x, :y
    def initialize
        @image = Gosu::Image.new("media/cash.png")
        @x = rand * 640
        @y = 0.0
    end
    def move
        @y += 1
    end
    def draw
        @image.draw(@x, @y, ZOrder::CASH, 0.05, 0.05)
    end
end

class Large_cash 
    attr_reader :x, :y
    def initialize
        @image = Gosu::Image.new("media/cash.png")
        @x = rand * 640
        @y = 0.0
    end
    def move
        @y += 10
    end
    def draw
        @image.draw(@x, @y, ZOrder::CASH, 0.1, 0.1)
    end
end

class Bomb 
    attr_reader :x, :y
    def initialize
        @image = Gosu::Image.new("media/bomb.png")
        @x = rand * 640
        @y = 0
    end
    def move
        @y += 3
    end
    def draw
        @image.draw(@x, @y, ZOrder::CASH, 0.09, 0.09)
    end
end

class Moneybomb < Gosu::Window
    def initialize
        super 640,480
        self.caption = "Money Bomb"

        @background_image = Gosu::Image.new("media/background.jpg", tileable: true)
       
        @player = Player.new
        @player.warp(320)

        @cashes = Array.new

        @large_cashes = Array.new

        @bombs = Array.new 

        @font = Gosu::Font.new(20)
    end

    def update 
        if Gosu.button_down? Gosu::KB_LEFT or Gosu::button_down? Gosu::GP_LEFT
            @player.accelerate
            @player.move_left
        end
        if Gosu.button_down? Gosu::KB_RIGHT or Gosu::button_down? Gosu::GP_RIGHT
            @player.accelerate
            @player.move_right
        end
        if Gosu.button_down? Gosu::KB_UP or Gosu::button_down? Gosu::GP_BUTTON_0
        end
        
        if !@player.nomorelifes
            @player.collect_cash(@cashes)
            @cashes.each {|cash| cash.move}
            if rand(100) < 4 and @cashes.size < 15
                @cashes.push(Cash.new)
            end

            @player.collect_largecash(@large_cashes)
            @large_cashes.each {|cash| cash.move}
            if rand(100) < 4 and @large_cashes.size < 10
                @large_cashes.push(Large_cash.new)
            end

            @player.hit_bombs(@bombs)
            @bombs.each {|bomb| bomb.move}
            if rand(100) < 2 && @bombs.size < 5
                @bombs.push(Bomb.new)
            end
        end
    end

    def draw 
        @background_image.draw(0, 0, ZOrder::BACKGROUND)
        if !@player.nomorelifes
            @player.draw
            @cashes.each do |cash| 
                cash.draw
            end
            @large_cashes.each do |large_cash| 
                large_cash.draw
            end
            @bombs.each do |bomb| 
                bomb.draw
            end
            @font.draw("Score: #{@player.score}", 10,10, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
            @font.draw("Attempt: #{@player.attempt}", 10, 25, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
        end
        
        if @player.nomorelifes
            @font.draw("Dead", 160, 120, ZOrder::UI, 10.0, 10.0, Gosu::Color::YELLOW)
            @font.draw("Hit dat space bar to play again yo", 170, 130, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
            if Gosu.button_down? Gosu::KB_SPACE
                @player.hit_spacebar
            end
        end
        
    end

    def button_down(id)
        if id == Gosu::KB_ESCAPE
            close
        else
            super
        end
    end
end


Moneybomb.new.show