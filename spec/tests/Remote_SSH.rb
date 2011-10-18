
describe "Remote SSH" do
  
  it "strips returned String" do
    Unified_IO::Remote::SSH.new.run("uptime").should == `uptime`.strip
  end
  
end # === describe Remote SSH
