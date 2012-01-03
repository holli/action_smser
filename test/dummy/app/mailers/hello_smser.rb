class HelloSmser < ActionSmser::Base
  def hello(to, from, body)
    sms(:to => to, :from => from, :body => body)
  end

  def hello_world()
    sms(:to => "123", :from => '123', :body => 'hello world')
  end
end