class HelloSmser < ActionSmser::Base
  def hello_world()
    sms(:to => "123", :from => '999', :body => 'hello world')
  end

  def hello_user(receiver, user_name)
    sms(:to => receiver, :from => '999', :body => "hello #{user_name}")
  end
end