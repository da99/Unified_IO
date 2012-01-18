
describe "Remote SSH" do
  
  behaves_like 'SSH to local'

  it "strips returned String" do
    target = `uptime`.strip.gsub(%r!\d+!, '[0-9]{1,2}')
    ssh_run("uptime").should.match %r!#{target}!
  end
  
  it "raises Wrong_IP when hostnames do not match" do
    lambda {
      # BIN("localhost uptime")
      localhost = Unified_IO::Remote::Server.new(
        :hostname=>'localhost',
        :group=>'App',
        :user=>`whoami`.strip
      )
      
      self.server = localhost
      ssh_run 'uptime'
    }.should.raise(Unified_IO::Remote::SSH::Wrong_IP)
    .message.match %r!Hostname: localhost, Target: !
  end
  
  it 'bypasses Wrong_IP check if ENV["SKIP_IP_CHECK"] exists.' do
    begin
      ENV['SKIP_IP_CHECK'] = 'true'
      
      lambda {
        localhost = Unified_IO::Remote::Server.new(
          :hostname=>'localhost',
          :group=>'App',
          :user=>`whoami`.strip
        )
        self.server = localhost
        ssh_run 'hostname'
      }.should.not.raise(Unified_IO::Remote::SSH::Wrong_IP)
    ensure
      ENV.delete 'SKIP_IP_CHECK'
    end
  end
  
  
end # === describe Remote SSH
              

__END__

  
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
  
  
