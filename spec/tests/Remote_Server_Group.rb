
describe "Server_Group" do
  
  it 'grabs all servers within that group' do
    Dir.chdir('spec/Boxes') {
      group = Unified_IO::Remote::Server_Group.new("Appster")
      group.servers.map(&:hostname).sort.should == %w{ s1 s2 }
    }
  end
  
  it 'grabs all servers for group "*"' do
    Dir.chdir('spec/Boxes') {
      group = Unified_IO::Remote::Server_Group.new("*")
      group.servers.map(&:hostname).sort.should == %w{ db1 s1 s2 }
    }
  end
  
end # === describe Server_Group
