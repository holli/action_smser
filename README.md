# ActionSmser

ActionSmser == SMS && ActionMailer. Simple way to use SMS (Short Message Service) in the same way as ActionMailer.
Includes also delivery reports and easy way to add custom gateways. See examples below.

# Install


## Common

```
Gemfile ->

gem 'action_smser'

# To use delivery reports
bundle exec rake railties:install:migrations
rake db:migrate
```

## SMS sending basic

**Initializing**

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

**Mailer classes**

```
in /app/mailers/test_sms.rb

class TestSms < ActionSmser::Base
  def hello_user(to, from, user)
    str = "Hello #{user}."
    sms(:to => to, :from => from, :body => str)
  end
end
```

**Sending sms**

```
E.g. from console or controller

sms = TestSms.hello_user('358407573855', '358407573855', "Olli")
sms.deliver
```

## Delivery methods

Optional delivery methods can be used by creating classes under "ActionSmser::DeliveryMethods" and referring
them as downcase infos. See example of :simple_http at
https://github.com/holli/action_smser/blob/master/lib/action_smser/delivery_methods/simple_http.rb

Simplest case is to use simple_http and override path

```
# Example of changing simple_http delivery path. Options are the same options that were presented above.

module ActionSmser::DeliveryMethods
  class SimpleHttp
    def self.deliver_path(sms, options)
      "/my_gateways_api/send?user=#{options[:username]}&password=#{options[:password]}&ValidityPeriod=24:00&sender=#{sms.from_encoded}&SMSText=#{sms.body_encoded_escaped}&GSM=#{sms.to_encoded}"
    end
  end
end

```

**Vonage/Nexmo** (http://nexmo.com/) is supported. Nexmo was renamed to Vonage, but naming has not been updated this lib.

```
  ActionSmser.delivery_options[:delivery_method] = :nexmo
  ActionSmser.delivery_options[:nexmo] = {
      :username => 'key', :password => "password"
  }

  # set callback url to nexmo http://localhost:3000/action_smser/delivery_reports/gateway_commit/nexmo
  ActionSmser.delivery_options[:gateway_commit]['nexmo'] = ActionSmser::DeliveryMethods::Nexmo

```

**DelayedJob** (https://github.com/collectiveidea/delayed_job)

```
  # Sending can often take couple seconds and you might want to do it in the background so that user gets instant feedback.
  # Need DelayedJob > 3.0.0 in your gemfile. Set the real delivery_method through delivery_options[:delayed_job]

  ActionSmser.delivery_options[:delayed_job] = { :delivery_method => :patidure, :priority => 0 }
```


If you add other common gateways to this framework, plz generate tests and send us a patch.


## Delivery reports

Gem handles collecting and analysing of delivery reports. This enables you to make sure that your gateway works.

Delivery reports and a summary can be seen at http://localhost.inv:3000/action_smser/delivery_reports/ .
Summary includes info about the amount of sent sms, delivery times, types of sms, etc.

Parsers and access infos can be implemented by creating a class with admin_access and process_delivery_report methods.
See example below.

```
in /config/initializers/active_smser.rb

ActionSmser.delivery_options[:save_delivery_reports] = true


class ActionSmserConfigExample
  # This returns true if we can show delivery reports page, return true if always permissed
  def self.admin_access(controller)
    if controller.session[:admin_logged].blank?
      return controller.session[:admin_logged]
    else
      return true
    end
  end

  # This has to return array of hashes. In hash msg_id is the key and other params are updated to db
  def self.process_delivery_report(request)
    params = request.params
    processable_array = []
    if params["DeliveryReport"] && params["DeliveryReport"]["message"]
      reports = params["DeliveryReport"]["message"]
      reports = [reports] unless reports.is_a?(Array)

      reports.each do |report|
        processable_array << {'msg_id' => report['id'], 'status' => report['status']}
      end
    end

    return processable_array
  end
end

# This is simple proc that is used in a before filter, if it returns true it allows access to
# http://localhost.inv:3000/action_smser/delivery_reports/ with infos about delivery reports
ActionSmser.delivery_options[:admin_access] = ActionSmserConfigExample

# Parser is used with urls like
# /action_smser/delivery_reports/gateway_commit/test_gateway
# where 'test_gateway' is the part that is used for locating right parser.
ActionSmser.delivery_options[:gateway_commit]['test_gateway'] = ActionSmserConfigExample

```

DeliveryReports can be searched by "dr = ::ActionSmser::DeliveryReport.where(xxx).first".
Some helpers in delivery_reports include

- dr.to_sms => creates new sms message from deliveryreport.
- dr.resent(:gateway) => creates new sms and sends it through given gateway.


## Other options

Observers can be used by implementing "delivery_observer" in your sms class

```
class TestSms < ActionSmser::Base
  def hello_user(to, from, user)
    str = "Hello #{user}."
    sms(:to => to, :from => from, :body => str)
  end

  def before_delivery()
    puts "Called just before delivery"
  end

  def after_delivery(response_from_delivery_method)
    puts "Done with delivery"
  end
end
```

Gateway committed status updates can also have observers

```
in /config/initializers/active_smser.rb

class ActionSmserConfigGatewayObserver
  def self.after_gateway_commit(delivery_reports)
    puts delivery_reports.inspect
  end
end

ActionSmser.gateway_commit_observer_add(ActionSmserConfigGatewayObserver)

```


## Testing

Default delivery method is "test_array". It saves delivered sms to ActionSmser::DeliveryMethods::TestArray.deliveries to help test your own software.
Its normal array, see sms by 'ActionSmser::DeliveryMethods::TestArray.deliveries' and
clear it between tests by 'ActionSmser::DeliveryMethods::TestArray.deliveries.clear'


```
E.g. in functional tests

test "should send right msg" do
  ActionSmser::DeliveryMethods::TestArray.deliveries.clear
  get :send_invite, :user_id => 1

  assert_equal 1, ActionSmser::DeliveryMethods::TestArray.deliveries.size
  assert_equal "UserSms.sent_invite", ActionSmser::DeliveryMethods::TestArray.deliveries.first.sms_type
end

```

# Support

Submit suggestions or feature requests as a GitHub Issue or Pull Request. Remember to update tests. Tests are quite extensive.

Check github actions for what environments are supported: https://github.com/holli/action_smser/blob/master/.github/workflows/ci.yaml and
https://github.com/holli/action_smser/actions . See https://github.com/holli/action_smser/blob/master/CHANGELOG.md for changes and to see what
version to use with older Rails versions.


### Similar gems

There are many gems to use custom gateways but none of them had a possibility to create classes like smser. Also these don't have
delivery reporting.

- https://github.com/dwilkie/action_sms
- https://github.com/forrestgrant/textr

# Licence

This project rocks and uses MIT-LICENSE. (http://www.opensource.org/licenses/mit-license.php)

