# ActionSmser

Simple way to use sms-services in the same way as email services (ActionSmser == ActionEmailer). See examples

# Install


## Common

```
Gemfile ->

gem 'action_smser'

bundle exec rake railties:install:migrations FROM=ActionSmser
rake db:migrate
```

## Setup

**Default**

```
in /config/initializers/active_smser.rb

if Rails.env.development? || Rails.env.production?

  ActionSmser.delivery_options[:delivery_method] = :simple_http
  ActionSmser.delivery_options[:simple_http] = {
      :server => 'server_to_use', :username => 'username', :password => 'password',
      :use_ssl => true
  }

  ActionSmser.delivery_options[:save_delivery_reports] = true
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

