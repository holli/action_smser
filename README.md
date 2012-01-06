# ActionSmser

Simple way to use sms-services in the same way as email services (ActionSmser == ActionEmailer). See examples below.

[<img src="https://secure.travis-ci.org/holli/action_smser.png" />](http://travis-ci.org/holli/action_smser)

# Install


## Common

```
Gemfile ->

gem 'action_smser'

bundle exec rake railties:install:migrations FROM=ActionSmser
rake db:migrate
```

## SMS sending basic

**Default**

```
in /config/initializers/active_smser.rb

if Rails.env.development? || Rails.env.production?

  ActionSmser.delivery_options[:delivery_method] = :simple_http
  ActionSmser.delivery_options[:simple_http] = {
      :server => 'server_to_use', :username => 'username', :password => 'password',
      :use_ssl => true
  }

  # ActionSmser.delivery_options[:save_delivery_reports] = true
end

```

```
in /app/mailers/test_sms.rb

class TestSms < ActionSmser::Base
  def hello_user(to, from, user)
    str = "Hello #{user}."
    sms(:to => to, :from => from, :body => str)
  end
end
```

```
Using

sms=TestSms.hello_user('358407573855', '358407573855', "Olli")
sms.deliver
```

## Delivery methods

Optional delivery methods can be used by creating classes under "ActionSmser::DeliveryMethods" and referring
them as downcase infos. See example of :simple_http at
https://github.com/holli/action_smser/blob/master/lib/action_smser/delivery_methods/simple_http.rb

## Delivery reports

Gem handles collecting and analysing of delivery reports. This enables you to make sure that your gateway works.

```
in /config/initializers/active_smser.rb

ActionSmser.delivery_options[:save_delivery_reports] = true

# This is simple proc that is used in a before filter, if it returns true it allows access to
# http://localhost.inv:3000/action_smser/delivery_reports/ with infos about delivery reports
ActionSmser.delivery_options[:admin_access] = ActionSmserConfigExample

# This gives ActionSmser way to parse infos from pushed to gateway
# Params is all params gotten in the request
test_gateway = lambda

# Parser is used with urls like
# /action_smser/delivery_reports/gateway_commit/test_gateway
# where 'test_gateway' is the part that is used for locating right parser.
ActionSmser.delivery_options[:gateway_commit] = {'test_gateway' => test_gateway}



class ActionSmserConfigExample

  def admin_access(controller)
    if controller.session[:admin_logged].blank?
      return controller.session[:admin_logged]
    else
      return true
    end
  end


  def process_delivery_report(params)
    if params["DeliveryReport"] && params["DeliveryReport"]["message"]
      info = params["DeliveryReport"]["message"]
      return info["id"], info["status"]
    else
      return nil, nil
    end
  end



end



```

## Other options

Observers can be used by implementing "delivery_observer" in your sms class

```
class TestSms < ActionSmser::Base
  def hello_user(to, from, user)
    str = "Hello #{user}."
    sms(:to => to, :from => from, :body => str)
  end

  def after_delivery(response_from_delivery_method)
    puts "Done with delivery"
  end
end
```

# Requirements

Gem has been tested with ruby 1.8.7, 1.9.2 and Rails 3.1.

[<img src="https://secure.travis-ci.org/holli/action_smser.png" />](http://travis-ci.org/holli/action_smser)

http://travis-ci.org/#!/holli/action_smser

# Support

Submit suggestions or feature requests as a GitHub Issue or Pull Request. Remember to update tests. Tests are quite extensive.


### Similar gems

There are many gems to use custom gateways but none of them had a possibility to create classes like smser.

- https://github.com/dwilkie/action_sms
- https://github.com/forrestgrant/textr

# Licence

This project rocks and uses MIT-LICENSE. (http://www.opensource.org/licenses/mit-license.php)

