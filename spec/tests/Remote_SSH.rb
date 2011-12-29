
describe "Remote SSH" do
  
  it "strips returned String" do
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
  
end # === describe Remote SSH
              

