RailsBootstrap::Application.routes.draw do

  post 'codes/redeem/' => 'codes#redeem'
  get '/samlauth/logout' => 'samlauth#logout'
  get '/samlauth/:saml' => 'samlauth#index'

  root to: 'main#index'


end
