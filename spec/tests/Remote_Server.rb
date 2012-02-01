
describe "Server :new Hash[]" do
  
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

  it 'sets :login to "root" if :root evalutes to true' do
    Unified_IO::Remote::Server.new(:user=>'user', :hostname=>'hostname', :root=>true)
    .login.should.be === 'root'
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

end # === describe Server
