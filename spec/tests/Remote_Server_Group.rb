
describe "Server_Group.new" do
  
  it 'grabs all servers within that group' do
    Dir.chdir('spec/Boxes') {
      group = Unified_IO::Remote::Server_Group.new("Appster")
      group.servers.map(&:hostname).sort.should == %w{ s1 s2 }
    }
  end
  
end # === describe Server_Group

describe "Server_Group.all" do
  
  it 'grabs all servers for group "*"' do
    Dir.chdir('spec/Boxes') {
      group = Unified_IO::Remote::Server_Group.all
      group.map(&:name).sort.should == %w{ Appster Db }
    }
  end

  it 'raises Server_Group::Not_Found if no servers are found' do
    lambda { Unified_IO::Remote::Server_Group.all }
    .should.raise(Unified_IO::Remote::Server_Group::Not_Found)
    .message.should.match %r!None!i
  end
  
end # === describe Server_Group.all
