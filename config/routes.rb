ActionSmser::Engine.routes.draw do

  match 'delivery_reports/gateway_commit/:gateway' => 'delivery_reports#gateway_commit', via: [:get, :post]

  resources :delivery_reports, :only => :index do
    get 'list', :on => :collection
  end

end
