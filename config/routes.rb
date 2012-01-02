ActionSmser::Engine.routes.draw do
  resources :helps

  match 'delivery_reports/gateway_commit/:gateway' => 'delivery_reports#gateway_commit'

  resources :delivery_reports


end
