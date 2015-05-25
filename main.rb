require "rubygems"
require "sinatra"
require "pry"

use Rack::Session::Cookie, key:     "rack.session",
                           path:    "/",
                           secret:  "my_secret"

helpers do
  def calculate_total(cards)
    arr = cards.map { |e| e[1] }

    total = 0
    arr.each do |value|
      if value == "Ace"
        total += 11
      elsif value.to_i == 0
        total += 10
      else
        total += value.to_i
      end
    end

    arr.select { |e| e == "Ace" }.count.times do
      total -= 10 if total > 21
    end

    total
  end
end

before do
  @show_hit_or_stay_buttons = true
end

get "/" do
  if session[:player_name]
    redirect "/game"
  else
    redirect "/new_player"
  end
end

get "/new_player" do
  erb :new_player
end

post "/new_player" do
  session[:player_name] = params[:player_name]
  redirect "/game"
end

get "/game" do
  suits = ["Hearts", "Diamonds", "Spades", "Clubs"]
  values = ["2", "3", "4", "5", "6", "7", "8", "9", "Jack", "Queen", "King", "Ace"]
  session[:deck] = suits.product(values).shuffle!

  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop

  erb :game
end

post "/game/player/hit" do
  session[:player_cards] << session[:deck].pop
  if calculate_total(session[:player_cards]) > 21
    @error = "Sorry, you busted."
    @show_hit_or_stay_buttons = false
  end
  erb :game
end

post "/game/player/stay" do
  @success = "You chose to stay."
  @show_hit_or_stay_buttons = false
  erb :game
end






