require "rubygems"
require "sinatra"
require "pry"

use Rack::Session::Cookie, key:     "rack.session",
                           path:    "/",
                           secret:  "my_secret"

helpers do
  def calculate_total(cards)
    arr = cards.map { |e| e[0] }

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

get "/" do
  erb :set_name
end

post "/set_name" do
  session[:player_name] = params[:player_name]
  redirect "/game"
end

get "/game" do
  session[:deck] = [["2", "H"], ["3", "D"]]
  session[:player_cards] = []
  session[:player_cards] << session[:deck].pop

  erb :game
end
