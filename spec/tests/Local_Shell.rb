
describe "Local Shell" do
  
  before { @shell = Unified_IO::Local::Shell }
  it 'must return value stripped.' do
    @shell.new.run("pwd").should.be == `pwd`.strip
  end

  it 'must run in a new login shell environment' do
    key = "BACON_TEST_1"
    val = "val_#{rand(100)}"
    ENV[key] = key
    results = @shell.new.run("env | grep #{key}" ).strip
    results[val].should.be == nil
  end
  
  it 'must raise a Failed for invalid shell commands' do
    lambda { @shell.new.run 'uptimes' }
    .should.raise(@shell::Failed)
    .message.should.match %r!COMMAND:!
  end

end # === describe :bash_shell
