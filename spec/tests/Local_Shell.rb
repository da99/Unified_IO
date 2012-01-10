
describe "Local Shell" do
  
  before { 
    @sh = begin
            s = Unified_IO::Local::Shell.new
            s.quiet
            s
          end
  }
  
  it 'must return value stripped.' do
    @sh.run("pwd").should.be == `pwd`.strip
  end

  it 'must run in a new login shell environment' do
    key = "BACON_TEST_1"
    val = "val_#{rand(100)}"
    ENV[key] = key
    results = @sh.run("env | grep #{key}" ).strip
    results[val].should.be == nil
  end
  
  it 'must raise a Failed for invalid shell commands' do
    lambda { @sh.run 'uptimes' }
    .should.raise(Unified_IO::Local::Shell::Failed)
    .message.should.match %r!sh: uptimes: not found!
  end

  it 'must print colored notifications.' do
    sh = Unified_IO::Local::Shell.new
    out = sh.capture_stdout {
      sh.notify "hello"
    }
    out.should.match %r!.\[\d\dmhello.\[0m!
  end

end # === describe :bash_shell
