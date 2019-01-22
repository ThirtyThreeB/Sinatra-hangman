require 'sinatra'
require 'sinatra/reloader' if development?
require 'yaml' 
require 'pry'  
require 'open-uri'

enable :sessions 

                                                                                                                                                                             
# $dictionary = File.read('colors.txt').split(/\n/)
                
$dictionary = open("https://www.scrapmaker.com/data/wordlists/basic/picturable.txt").read.split(/\n/)
                                                                                                                                                                                                
class Game                                                                                                                                                                                        
  attr_accessor :word, :guesses_remaining, :results, :last_guess_good, :last_guess, :game_won, :game_lost, :saved_game                                                                                                                                                                               
                                                                                                                                                                                                  
  def initialize(data = {}) #use data if passed, otherwise default is {}                                                                                                                                                                       
    @word               = data[:word] || $dictionary.sample.upcase                                                                                                                                                          
    @guesses_remaining  = data[:guesses_remaining] || 10

    @word_array         = word.chars.to_a
    @results            = data[:results] || "_"*word.length
    @last_guess_good    = data[:last_guess_good] || true
    @game_lost          = false             
    @game_won           = false 
    @saved_game         = data[:saved_game] || false   
    @last_guess         = ''
    p "INITIALIZED"                                                                                                                   
  end                                                                                                                                                                                                                  
                                                                                                                                                                                                  
  def save_game 
p __method__                                                                                                                                                                                      
    File.open('saved_game.yml', 'w') do |f|                                                                                                                                                       
      f.write self.to_yaml                                                                                                                                                                        
    end
    @saved_game = true  
    # game = Game.new                                                                                                                                                                                         
  end    

  def load_game
p __method__
    data = YAML::load(File.read('saved_game.yml'))
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
                                                                                                                                                                                                  
 

get '/home' do
  p "HOT DIGGITY" if session[:game].nil?
  get_game
  @last_guess = params[:last_guess]
  @game = session[:game]

  erb :index
end

post '/' do
  @last_guess = params[:last_guess].upcase
  game = session[:game]
p game
  game.check_guess(@last_guess)
  game.decrement_guesses
  game.check_win

   if game.game_lost || game.game_won
    redirect "/game_over" 
   else 
    redirect "/home?last_guess=#{@last_guess}" 
  end
end

post '/save' do
  game  = session[:game]
  game.save_game
  redirect '/home'
end

post '/load' do
  game  = session[:game]
  game = game.load_game  ###############fixit, also this is where the saved game data gets written over the current game
  session[:game] = game

  redirect '/home'
end

get '/game_over' do

  @game  = session[:game]
  p session[:game]
  erb :game_over
end

get '/reset' do

  session[:game] = nil

  redirect '/home'
end

private

def get_game(som ={})
p __method__

    session[:game] ||= Game.new # unless session[:game]  #memoization
end

#_____________________________


#css fix input panel
# show only save or load?

#figure out partial templates so other routes keep styling


