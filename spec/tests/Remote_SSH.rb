
describe ":ssh_exec" do
  
  behaves_like 'SSH to local'
  
  before do
    @wrong_ip = Unified_IO::Remote::Server.new(
      :hostname=> 'localhost',
      :group=>'Apps',
      :user=>`whoami`.strip
    ) 
  end
  
  after { ENV.delete 'SKIP_IP_CHECK' }
  
  it "raises Wrong_IP when hostnames do not match" do
    lambda {
      server @wrong_ip
      ssh_exec 'uptime'
    }.should.raise(Unified_IO::Remote::SSH::Wrong_IP)
    .message.match %r!Hostname: localhost, Target: !
  end
  
  it 'bypasses Wrong_IP check if ENV["SKIP_IP_CHECK"] exists.' do
    begin
      lambda {
        ENV['SKIP_IP_CHECK'] = 'true'
        server @wrong_ip
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
  
  it 'uses :ip, not :hostname' do
    ENV['SKIP_IP_CHECK'] = 'true'
    
    server Unified_IO::Remote::Server.new(
      :hostname=> 'InVaLiD',
      :ip => `hostname`.strip,
      :group=>'Apps',
      :user=>`whoami`.strip
    ) 
    ssh_exec('hostname').data.first.should.be == `hostname`.strip
  end
  
  it 'raises Exit_Error if status is 0, but :errors is not empty' do
    `bundle exec ruby spec/files/errors_with_exit_0.rb 2>&1`.strip
    .should == "err msg 1\nerr msg 2\nExit: 0"
  end

  it 'raises Exit_Error if status does not equal 0' do
    `bundle exec ruby spec/files/exit_with_2.rb 2>&1`.strip
    .should == "Exiting\n\n2"
  end

  it 'uses a PTY' do
    `bundle exec ruby spec/files/run_pty.rb 2>&1`.strip
    .should == %~[sudo] password for da01: a
Sorry, try again.~
  end

end # === describe :ssh_exec

describe ":ssh_run" do
  
  behaves_like 'SSH to local'
  
  it "returns a stripped String" do
    target = `uptime`.strip.gsub(%r!\d+!, '[0-9]{1,2}')
    ssh_run("uptime").should.match %r!#{target}!
  end

end # === describe :ssh_run
           
describe ":ssh_exits" do
  
  behaves_like 'SSH to local'
  
  it 'captures exits based on key => int, val => Regexp' do
    lambda {
      ignore_exits("cat something.txt", 1=>%r!something\.txt\: No such file or directory!)
    }.should.not.raise
  end
  
  it 'captures exits based on key => int, val => String' do
    lambda {
      ignore_exits("cat something.txt", 1=>'something.txt: No such file or directory') 
    }.should.not.raise
  end
  
  it 'returns SSH::Results for a non-zero exit status' do
    ignore_exits("cat something.txt", 1=>'something.txt: No such file or directory')
    .should.be.is_a Unified_IO::Remote::SSH::Results
  end
  
  it 'returns SSH::Results for a zero exit status' do
    ignore_exits("uptime", 1=>'something.txt: No such file or directory')
    .should.be.is_a Unified_IO::Remote::SSH::Results
  end
  
end # === describe :ssh_exits
  
