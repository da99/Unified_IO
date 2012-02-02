
describe "Server :new Hash[]" do
  
  it 'requires a hash' do
    lambda {
      Unified_IO::Remote::Server.new('s1')
    }.should.raise(ArgumentError)
    .message.should.match %r!not a hash!
  end

  it 'must require :hostname' do
    lambda {
      Unified_IO::Remote::Server.new(
        :user=>'user'
      )
    }.should.raise(Unified_IO::Remote::Server::Invalid_Property)
    .message.should.match %r!Hostname!i
  end

  it 'must raise Invalid_Property for mis-spelled property' do
    lambda {
      Unified_IO::Remote::Server.new(
        :user=>'user',
        :hostname=>'app',
        :nickname=>'CONAN'
      )
    }.should.raise(Unified_IO::Remote::Server::Invalid_Property)
    .message.should.match %r!Nickname!i
  end

  it 'sets a default port of 22' do
    Unified_IO::Remote::Server.new(:user=>'user', :hostname=>'hostname')
    .port.should.be == 22
  end
  
  it 'sets a default :login equal to value of :user' do
    Unified_IO::Remote::Server.new(:user=>'me', :hostname=>'hostname')
    .login.should.be == 'me'
  end
  
  it 'raises ArgumentError if Integer() does not accept it' do
    lambda {
      Unified_IO::Remote::Server.new(:user=>'me', :hostname=>'hostname', :port=>'o22')
    }.should.raise(ArgumentError)
    .message.should.match %r!o22!
  end
  
  it 'accepts a :custom field' do
    target = [:group]
    Unified_IO::Remote::Server.new({:user=>'me', :hostname=>'hostname', :group=>'group'}, :custom=>target)
    .custom.should == target
  end
  
  it 'defines, on meta class, methods from custom field' do
    target = [:group]
    Unified_IO::Remote::Server.new({:user=>'me', :hostname=>'hostname', :group => 'Apps'}, :custom=>target)
    .group.should == 'Apps'
  end
  
  it 'requires values from :custom field' do
    lambda {
      Unified_IO::Remote::Server.new({:user=>'me', :hostname=>'hostname'}, :custom=>[:group])
    }.should.raise(Unified_IO::Remote::Server::Missing_Property)
    .message.should.match %r!group!
  end
  
  it 'sets default :user to value of :login' do
    Unified_IO::Remote::Server.new(:login=>'you', :hostname=>'hostname')
    .user.should == 'you'
  end
  
  it 'sets default :login to value of :user' do
    Unified_IO::Remote::Server.new(:user=>'me', :hostname=>'hostname')
    .user.should == 'me'
  end

  it 'raises Missing_Property if :login and :user is not provided' do
    lambda {
      Unified_IO::Remote::Server.new({:hostname=>'hostname'})
    }.should.raise(Unified_IO::Remote::Server::Missing_Property)
    .message.should.match %r!login, :user!
  end
  
  it 'raises Invalid_Property if :custom includes non-symbol keys' do
    lambda {
      Unified_IO::Remote::Server.new({:user=>'me', :hostname=>'hostname'}, :custom=>["group"])
    }.should.raise(Unified_IO::Remote::Server::Invalid_Property)
    .message.should.match %r!group!
  end

  it 'raises Invalid_Property if :custom inclues an already defined method name' do
    lambda {
      Unified_IO::Remote::Server.new({:user=>'me', :hostname=>'hostname', :inspect=>'yo'}, :custom=>[:inspect])
    }.should.raise(Unified_IO::Remote::Server::Invalid_Property)
    .message.should.match %r!:inspect already defined!
  end

end # === describe Server
