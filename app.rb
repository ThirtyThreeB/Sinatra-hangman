require 'sinatra'
require 'sinatra/reloader'
require 'yaml'      

enable :sessions                                                                                                                                                                              
                                                                                                                                                                                                  
class Game                                                                                                                                                                                        
  attr_accessor :word, :guesses_remaining, :results, :last_guess_good, :game_won, :game_lost, :saved_game                                                                                                                                          
                                                                                                                                                                                                  
  def self.load                                                                                                                                                                                   
    if File.exists?('game.yml')                                                                                                                                                                    
      Game.new(YAML.load('game.yml'))  #this is that data passed to initialize                                                                                                                                                           
    else                                                                                                                                                                                          
      Game.new                                                                                                                                                                                    
    end                                                                                                                                                                                           
  end                                                                                                                                                                                             
                                                                                                                                                                                                  
  def initialize(data = {}) #use data if passed, otherwise default is {}                                                                                                                                                                       
    @word               = data[:word] || "sa"                                                                                                                                                          
    @guesses_remaining  = data[:guesses_remaining] || 2
    @word_array         = word.chars.to_a
    @results       = data[:results] || "_"*word.length
    @last_guess_good    = data[:last_guess_good] || true
    @game_lost          = false             
    @game_won           = false 
    @saved_game         = false                                                                                                                      
  end                                                                                                                                                                                                                  
                                                                                                                                                                                                  
  def save_game                                                                                                                                                                                       
    File.open('saved_game.yml', 'w') do |f|                                                                                                                                                       
      f.write self.to_yaml                                                                                                                                                                        
    end
    @saved_game = true                                                                                                                                                                                           
  end    

  def decrement_guesses
    @guesses_remaining -= 1
p __method__
  end

  #returns true if the guess is included in the array
  def check_guess(player_guess)
p __method__
    if !@word_array.include?(player_guess)
      @last_guess_good = false
    else
      @last_guess_good = true
      match_letters(player_guess)
    end
  end

  #check which indexes in word match the guess, set the guess at those indexes.  Allows guess to match words with duplicate+ letters
  def match_letters(player_guess)   
p __method__

    indexes_matched = @word_array.each_index.select { |i| @word_array[i] == player_guess}
      for x in indexes_matched do
        @results[x] = player_guess
      end
  end

  def check_win
p __method__
    
  if @word_array.join == @results
    @game_won = true
p "GAMEWON"
  elsif @guesses_remaining == 0
    @game_lost = true
p "GAMELOST"

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
p session[:game]
  @game = game
 
  erb :index
end

post '/' do
  @last_guess = params[:last_guess]
  game = session[:game]

  game.check_guess(@last_guess)
  game.decrement_guesses
  game.check_win

   if game.game_lost || game.game_won
    redirect "/game_over" 
   else 
    redirect "/home?guess=#{@last_guess}" 
  end
end

post '/save' do
  game  = session[:game]
  @game = game
  game.save_game
  redirect '/home'
end

get '/game_over' do
  # get_game
  game  = session[:game]
  @game = game
  
  erb :game_over
end

private

def get_game
p __method__
#   if session[:game]
# p "the if: session[:game] exists"
#     session[:game]
#   else
# p "the else: no game, Game.new"
#     session[:game] = Game.new   
#   end
  session[:game] = Game.new unless session[:game]
end