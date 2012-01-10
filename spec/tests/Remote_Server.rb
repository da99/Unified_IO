describe "Server.server?" do
  
  it "returns true if dir/file exists for server." do
    Dir.chdir("spec/Boxes") {
      Unified_IO::Remote::Server.server?('s1').should.be === true
    }
  end

  it "returns false if dir/file does not exist." do
    Dir.chdir("spec/Boxes") {
      Unified_IO::Remote::Server.server?('Krypton').should.be === false
    }
  end
  
end # === describe Server.server?

describe "Server.group?" do
  
  it "returns true if dir/file exists for group." do
    Dir.chdir("spec/Boxes") {
      Unified_IO::Remote::Server.group?('Appster').should.be === true
    }
  end

  it "returns false if dir/file does not exist." do
    Dir.chdir("spec/Boxes") {
      Unified_IO::Remote::Server.group?('DATA').should.be === false
    }
  end
  
end # === describe Server.group?

describe "Server.all" do
  
  it 'returns an array of Remote_Server objects' do
    Dir.chdir('spec/Boxes') {
      all = Unified_IO::Remote::Server.all
      all.map(&:hostname).sort.should == %w{ db1 s1 s2 }
    }
  end
  
  it 'raises Server:Not_Found if no servers are found' do
    lambda { Unified_IO::Remote::Server.all }
    .should.raise(Unified_IO::Remote::Server::Not_Found)
    .message.should.match %r!None!i
  end
  
end # === describe Server.all

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
