
describe "Server" do
  
  it 'must require :group' do
    lambda {
      Unified_IO::Remote::Server.new(
        :hostname=>'localhost', 
        :user=>'user'
      )
    }.should.raise(Unified_IO::Remote::Server::Invalid_Property)
    .message.should.match %r!Group!i
  end
  
  it 'must require :hostname' do
    lambda {
      Unified_IO::Remote::Server.new(
        :group=>'Local', 
        :user=>'user'
      )
    }.should.raise(Unified_IO::Remote::Server::Invalid_Property)
    .message.should.match %r!Hostname!i
  end

  it 'must raise Invalid_Property for mis-spelled property' do
    lambda {
      Unified_IO::Remote::Server.new(
        :group=> 'Local',
        :user=>'user',
        :hostname=>'app',
        :nickname=>'CONAN'
      )
    }.should.raise(Unified_IO::Remote::Server::Invalid_Property)
    .message.should.match %r!Nickname!i
  end
  
end # === describe Server
