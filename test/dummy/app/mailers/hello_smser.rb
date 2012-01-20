# encoding: utf-8
class HelloSmser < ActionSmser::Base
  def hello(to, from, body)
    sms(:to => to, :from => from, :body => body)
  end

  def hello_world()
    sms(:to => "123", :from => '123', :body => 'hello world')
  end

  def hello_olli()
    sms(:to => '358407573855', :from => 'ActionSmser', :body => 'Hello from action smser, encode ääkköset!#')
  end
end