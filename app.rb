require 'sinatra'
require 'sinatra/reloader'
require 'yaml'      

enable :sessions                                                                                                                                                                              
                                                                                                                                                                                                  
class Game                                                                                                                                                                                        
  attr_accessor :word, :guesses_remaining, :result_array                                                                                                                                                                             
                                                                                                                                                                                                  
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
    @result_array       = "_"*word.length || guesses_remaining                                                                                                                                        
  end                                                                                                                                                                                             
                                                                                                                                                                                                  
  # def print_word                                                                                                                                                                                  
  #   p @word                                                                                                                                                                                       
  # end                                                                                                                                                                                             
                                                                                                                                                                                                  
  def save                                                                                                                                                                                        
    File.open('saved_game.yml', 'w') do |f|                                                                                                                                                       
      f.write self.to_yaml                                                                                                                                                                        
    end                                                                                                                                                                                           
  end    

  def guess(guess)

     # handle_guess(game.good_guess?(params[:last_guess]))
  end


  def decrement_guesses
    @guesses_remaining -= 1
    # @guesses_remaining = guesses
# p __method__
  end

  #returns true if the guess is included in the array
  def bad_guess?(player_guess)
# p __method__
    true if !@word_array.include?(player_guess)

    match_letters
  end

   #calls match_letters!!
  def handle_good_guess
# p __method__  
    # session[:message] = "Nice, you got a match"
    match_letters# pass args in here?

  end

  #check which indexes in word match the guess, set the guess at those indexes.  Allows guess to match words with duplicate+ letters
  def match_letters  # these args? (word_array, guess) 
# p __method__require 'sinatra'
    indexes_matched = @word_array.each_index.select { |i| @word_array[i] == @last_guess}
    for x in indexes_matched do
      @result_array[x] = @last_guess
    end
# p "L51"
  end

  def check_win
    if @guesses_remaining == 0
      # session[:message] = "It's all over, you're out of guesses, the word was #{session[:word]}"
      @game_won = true
    elsif @word_array == @result_array
      # session[:message] = "Aw yeah.  You win!"
      @game_lost = true
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
# p "line 99 session #{session}"
  get_game
  game = session[:game]

  p session[:game]
  
  @word               = game.word
  @guesses_remaining  = game.guesses_remaining
  @result_array       = game.result_array
p @result_array
  @last_guess         = params[:guess]
p @last_guess

p "YOU GOT GAME /home" if session[:game] 
  # @message            = "You have #{@guesses_remaining} chances to guess the word."
  
  erb :index
end

post '/' do
   # Game.tester

p "YOU GOT GAME /" if session[:game]

  @last_guess = params[:last_guess]
  # p params.inspect

  game = session[:game]

  p " line 122 #{session[:game]}"

  game.bad_guess?(@last_guess)

  game.decrement_guesses

  game.check_win
# p "l128ish"

  redirect "/game_over" if @game_won || @game_lost  #maybe 

p "L130ish"
  redirect "/home?guess=#{@last_guess}" 
end

post '/save' do
  save_game(params[:game_name], session)
  redirect '/home'
end

# private

def get_game
  # p 
p "#{__method__},session or no >>#{session[:game]}"
  if session[:game]
    p "the if"
    session[:game]
    
  else
    p "the else"
    session[:game] = Game.new

    
    p "else session >> #{session[:game]}"
    # get_game
  end
end