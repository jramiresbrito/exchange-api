Rails.application.routes.draw do
  get '/bids', to: 'bids#index'
  get '/transactions', to: 'transactions#index'
end
