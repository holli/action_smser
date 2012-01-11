ActionSmser::Engine.routes.draw do

  match 'delivery_reports/gateway_commit/:gateway' => 'delivery_reports#gateway_commit'

  resources :delivery_reports, :only => :index

end
