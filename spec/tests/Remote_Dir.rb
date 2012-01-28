
describe "Remote::Dir.new" do
  
  it 'must return true for remote?' do
    Unified_IO::Remote::Dir.new('~/').remote?.should.be == true
  end
  
  it 'must not expand the path' do
    Unified_IO::Remote::Dir.new('~/').address
    .should.be == File.expand_path('~/')
  end

end # === describe Remote::Dir.new

describe "Remote::Dir :exist!" do
  
  behaves_like 'SSH to local'

  it 'must raise Not_Found if dir does not exist' do
    
    m = lambda { 
     f = Unified_IO::Remote::Dir.new("/VIDEOS")
     f.server = @localhost
     f.exists!
    }.should.raise(Unified_IO::Remote::Dir::Not_Found)
    .message
    
    m.should.match %r!Remote dir, "?/VIDEOS"?, must exist!
  end

end # === describe file!
