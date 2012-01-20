
#if Rails.env.development? || Rails.env.production?
#
#  ActionSmser.delivery_options[:delivery_method] = :simple_http
#  ActionSmser.delivery_options[:simple_http] = {
#      :server => 'server_to_use', :username => 'username', :password => 'password',
#      :use_ssl => true
#  }
#
#  # ActionSmser.delivery_options[:save_delivery_reports] = true
#end
