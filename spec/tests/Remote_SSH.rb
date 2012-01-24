
describe ":ssh_exec" do
  
  behaves_like 'SSH to local'
  
  before do
    @wrong_ip = Unified_IO::Remote::Server.new(
      :hostname=> 'localhost',
      :group=>'Apps',
      :user=>`whoami`.strip
    ) 
  end
  
  it "raises Wrong_IP when hostnames do not match" do
    lambda {
      self.server = @wrong_ip
      ssh_exec 'uptime'
    }.should.raise(Unified_IO::Remote::SSH::Wrong_IP)
    .message.match %r!Hostname: localhost, Target: !
  end
  
  it 'bypasses Wrong_IP check if ENV["SKIP_IP_CHECK"] exists.' do
    begin
      lambda {
        ENV['SKIP_IP_CHECK'] = 'true'
        self.server = @wrong_ip
        ssh_exec 'hostname'
      }.should.not.raise(Unified_IO::Remote::SSH::Wrong_IP)
    ensure
      ENV.delete 'SKIP_IP_CHECK'
    end
  end
  
  it 'raises SSH::Exit_Error if return status is not zero' do
    e = lambda {
      ssh_exec "HOSTNAMES"
    }.should.raise(Unified_IO::Remote::SSH::Exit_Error)

    e.result.exit_status.should == 127
  end
  
  it 'returns a SSH::Results' do
    ssh_exec("hostname").should.be.is_a Unified_IO::Remote::SSH::Results
  end
  
  it "strips returned data" do
    target = `uptime`.strip.gsub(%r!\d+!, '[0-9]{1,2}')
    ssh_exec("uptime").data.join.should.match %r!#{target}!
  end
  
  it 'returns a SSH::Results with an array of data' do
    ssh_exec("whoami").data.should.be == [`whoami`.strip]
  end

end # === describe :ssh_exec

describe ":ssh_run" do
  
  behaves_like 'SSH to local'
  
  it "returns a stripped String" do
    target = `uptime`.strip.gsub(%r!\d+!, '[0-9]{1,2}')
    ssh_run("uptime").should.match %r!#{target}!
  end

end # === describe :ssh_run
           
  
  
