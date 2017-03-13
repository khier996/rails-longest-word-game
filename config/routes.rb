Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/game', to: "playing#game"
  get "/score", to: "playing#score"
end
