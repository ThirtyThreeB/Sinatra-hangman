require 'sinatra'
require 'sinatra/reloader'
require 'yaml'      

enable :sessions                                                                                                                                                                              
                                                                                                                                                                                                  
class Game                                                                                                                                                                                        
  attr_accessor :word, :guesses_remaining, :result_array, :last_guess_good, :game_won, :game_lost                                                                                                                                                                             
                                                                                                                                                                                                  
  def self.load                                                                                                                                                                                   
    if File.exists?('game.yml')                                                                                                                                                                    
      Game.new(YAML.load('game.yml'))  #this is that data passed to initialize                                                                                                                                                           
    else                                                                                                                                                                                          
      Game.new                                                                                                                                                                                    
    end                                                                                                                                                                                           
  end                                                                                                                                                                                             
                                                                                                                                                                                                  
  def initialize(data = {}) #use data if passed, otherwise default is {}                                                                                                                                                                       
    @word               = data[:word] || "sample"                                                                                                                                                          
    @guesses_remaining  = data[:guesses_remaining] || 10
    @word_array         = word.chars.to_a
    @result_array       = data[:result_array] || "_"*word.length
    @last_guess_good    = data[:last_guess_good] || true
    @game_lost          = false             
    @game_won           = false                                                                                                                       
  end                                                                                                                                                                                                                  
                                                                                                                                                                                                  
  def save                                                                                                                                                                                        
    File.open('saved_game.yml', 'w') do |f|                                                                                                                                                       
      f.write self.to_yaml                                                                                                                                                                        
    end                                                                                                                                                                                           
  end    

  def decrement_guesses
    @guesses_remaining -= 1
    # @guesses_remaining = guesses
    p __method__
  end

  #returns true if the guess is included in the array
  def check_guess(player_guess)
p __method__
    if !@word_array.include?(player_guess)
p "NO MATCH"
      @last_guess_good = false
    else
p "MATCH"
      @last_guess_good = true
      match_letters(player_guess)
    end
  end

  #check which indexes in word match the guess, set the guess at those indexes.  Allows guess to match words with duplicate+ letters
  def match_letters(player_guess)   
p __method__

    indexes_matched = @word_array.each_index.select { |i| @word_array[i] == player_guess}
    for x in indexes_matched do
      @result_array[x] = player_guess
    end
  end

  def check_win
p __method__

    if @guesses_remaining == 0
      @game_lost = true
p "GAMELOST"
    elsif @word_array == @result_array
      @game_won = true
p "GAMEWON"
    end
  end

  def self.tester
    puts 'THIS IS A TEST'
    p __method__
  end                                                                                                                                                                                         
                                                                                                                                                                                                  
end                                                                                                                                                                                               
                                                                                                                                                                                                  
                                                                                                                                                                                   
# game.save                                                                                                                                                                                         
                                                                                                                                                                                                  
# game = Game.load                                                                                                                                                                                  
                                                                                                                                                                                                  
                                                                                                                                                                                                  
# def home                                                                                                                                                                                          
#   @game = Game.load                                                                                                                                                                               
# end  

get '/home' do
  get_game
  game = session[:game]

p "#L124#{session[:game]}"

  game.check_win
p "#L127#{session[:game]}"
p session[:game]

  @game = game

#   @word               = game.word
# # p @word
#   @guesses_remaining  = game.guesses_remaining
# # p @guesses_remaining
#   @result_array       = game.result_array
# p @result_array
  @last_guess         = params[:guess]

p "YOU GOT GAME /home" if session[:game] 
  
  erb :index
end

post '/' do
   # Game.tester
  @last_guess = params[:last_guess]

  game = session[:game]

  game.check_guess(@last_guess)

  game.decrement_guesses

  game.check_win

p " line 149 #{session[:game]}"

p "GAME LOST???? = #{game.game_lost}"  ############# this isnt getting set
p game.game_lost
   if game.game_lost || game.game_lost
    redirect "/game_over" 
   else 
p "L160ish"
    redirect "/home?guess=#{@last_guess}" 
  end
end

post '/save' do
  save_game(params[:game_name], session)
  redirect '/home'
end

# private

def get_game
p __method__
  if session[:game]
p "the if: session[:game] exists"
    session[:game]
  else
p "the else: no game, Game.new"
    session[:game] = Game.new   
  end
end