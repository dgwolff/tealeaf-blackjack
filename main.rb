require "rubygems"
require "sinatra"

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

  def card_image(card)
    suit = case card[0]
           when "H" then "hearts"
           when "D" then "diamonds"
           when "C" then "clubs"
           when "S" then "spades"
    end

    value = card[1]
    if ["J", "Q", "K", "A"].include?(value)
      value = case card[1]
              when "J" then "jack"
              when "Q" then "queen"
              when "K" then "king"
              when "A" then "ace"
              end
    end

    "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
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
  if params[:player_name].empty?
    @error = "Name is required"
    halt erb(:new_player)
  end

  session[:player_name] = params[:player_name]
  redirect "/game"
end

get "/game" do
  suits = ["H", "D", "S", "C"]
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

  player_total = calculate_total(session[:player_cards])
  if player_total == 21
    @success = "You hit Blackjack!"
    @show_hit_or_stay_buttons = false
  elsif player_total > 21
    @error = "You busted, dealer wins!"
    @show_hit_or_stay_buttons = false
  end

  erb :game
end

post "/game/player/stay" do
  @success = "You chose to stay"
  @show_hit_or_stay_buttons = false
  redirect "/game/dealer"
end

get "/game/dealer" do
  @show_hit_or_stay_buttons = false

  dealer_total =  calculate_total(session[:dealer_cards])

  if dealer_total == 21
    @error = "Dealer hit Blackjack!"
  elsif dealer_total > 21
    @success = "Dealer busted!"
  elsif dealer_total >= 17
    redirect "/game/compare"
  else
    @show_dealer_hit_button = true
  end

  erb :game
end

post "/game/dealer/hit" do
  session[:dealer_cards] << session[:deck].pop
  redirect "/game/dealer"
end

get "/game/compare" do
  @show_hit_or_stay_buttons = false

  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])

  if player_total < dealer_total
    @error = "Dealer wins!"
  elsif player_total > dealer_total
    @success = "You win!"
  else
    @success = "It's a tie!"
  end

  erb :game
end
