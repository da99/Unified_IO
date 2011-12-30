
describe "Remote SSH" do
  
  behaves_like 'SSH to local'

  it "strips returned String" do
    @connect.call
    Unified_IO::Remote::SSH.new.run("uptime").should == `uptime`.strip
  end
  
  it 'sets :disconnected? to the states of the :connection' do
    BOX.bundle("ruby spec/files/Disconnection.rb").split.should == %w{ same same same }
  end
  
  it "closes a connection at ending" do
    BOX.bundle("ruby spec/files/Close_At_Exit.rb").strip.should == "closed"
  end
  
  it "allows multiple closings of a connection" do
    BOX.bundle("ruby spec/files/Multi_Close.rb").strip.should == "all closed"
  end
  
  it "can open a new connection after closing an old one." do
    BOX.bundle("ruby spec/files/Multi_Open.rb").strip.should == "opened/closed all"
  end
  
  it "raises Wrong_IP when hostnames do not match" do
    Unified_IO::Remote::SSH.disconnect
    
    lambda {
      # BIN("localhost uptime")
      localhost = Unified_IO::Remote::Server.new(
        :hostname=>'localhost',
        :group=>'App',
        :user=>`whoami`.strip
      )
      Unified_IO::Remote::SSH.connect(localhost)
    }.should.raise(Unified_IO::Remote::SSH::Wrong_IP)
    .message.match %r!HOSTNAME: localhost, TARGET: #{`hostname`.strip}!
  end
  
  it 'bypasses Wrong_IP check if file /tmp/skip_ip_check.txt exists.' do
    begin
      file = "/tmp/skip_ip_check.txt"
      `touch #{file}`
      
      lambda {
      localhost = Unified_IO::Remote::Server.new(
        :hostname=>'localhost',
        :group=>'App',
        :user=>`whoami`.strip
      )
      Unified_IO::Remote::SSH.connect(localhost)
      }.should.not.raise(Unified_IO::Remote::SSH::Wrong_IP)
    ensure
      `rm #{file}` if File.exists?(file)
    end
  end
  
end # === describe Remote SSH
              

