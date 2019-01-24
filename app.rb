require 'sinatra'
require 'sinatra/reloader' if development?
require 'yaml' 
require 'pry' if development? 
require 'open-uri'

enable :sessions 
                                                                                                                                                                           
               
$dictionary = open("https://www.scrapmaker.com/data/wordlists/basic/picturable.txt").read.split(/\n/)
                                                                                                                                                                                                
class Game                                                                                                                                                                                        
  attr_accessor :word, :guesses_remaining, :results, :last_guess_good, :last_guess, :game_won, :game_lost, :saved_game                                                                                                                                                                               
                                                                                                                                                                                                  
  def initialize                                                                                                                                                                       
    @word               = $dictionary.sample.upcase                                                                                                                                                          
    @guesses_remaining  = 10
    @word_array         = word.chars.to_a
    @results            = "_"*word.length
    @last_guess_good    = true
    @game_lost          = false             
    @game_won           = false 
    @saved_game         = false   
    @last_guess         = ''
  end                                                                                                                                                                                                                  
                                                                                                                                                                                                  
  def save_game                                                                                                                                                                                      
    File.open('saved_game.yml', 'w') do |f|                                                                                                                                                       
      f.write self.to_yaml                                                                                                                                                                        
    end
    @saved_game = true  
  end    

  def load_game
    data = YAML::load(File.read('saved_game.yml'))
  end

  def decrement_guesses
    @guesses_remaining -= 1
  end

  def check_guess(player_guess)
    if !@word_array.include?(player_guess)
      @last_guess_good = false
    else
      @last_guess_good = true
      match_letters(player_guess)
    end
  end

  #check which indexes in word match the guess, set the guess at those indexes.  Allows guess to match words with duplicate+ letters
  def match_letters(player_guess)   
    indexes_matched = @word_array.each_index.select { |i| @word_array[i] == player_guess}
      for x in indexes_matched do
        @results[x] = player_guess
      end
  end

  def check_win   
    if @word_array.join == @results
      @game_won = true
    elsif @guesses_remaining == 0
      @game_lost = true
    end
  end
                                                                                                                                                                                             
end                                                                                                                                                                                               
                                                                                                                                                                                                  
 

get '/' do
  get_game
  @last_guess = params[:last_guess]
  @game = session[:game]

  erb :game_layout
end

post '/' do
  @last_guess = params[:last_guess].upcase
  game = session[:game]
  game.check_guess(@last_guess)
  game.decrement_guesses
  game.check_win

   if game.game_lost || game.game_won
    redirect "/game_over" 
   else 
    redirect "/?last_guess=#{@last_guess}" 
  end
end

post '/save' do
  game  = session[:game]
  game.save_game

  redirect '/'
end

post '/load' do
  game  = session[:game]
  game = game.load_game  ###############fixit, also this is where the saved game data gets written over the current game
  session[:game] = game

  redirect '/'
end

get '/game_over' do
  @game  = session[:game]

  erb :game_over, {:layout => :game_layout}
end

get '/reset' do
  session[:game] = nil

  redirect '/'
end

private

def get_game
    session[:game] ||= Game.new # unless session[:game]  #memoization
end

