
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
     f.server @localhost
     f.exists!
    }.should.raise(Unified_IO::Remote::Dir::Not_Found)
    .message
    
    m.should.match %r!Remote dir, "?/VIDEOS"?, must exist!
  end

end # === describe file!


describe "Remote::Dir :permissions" do
  
  behaves_like 'SSH to local'
  
  it 'must return permissions as an octal string' do
    dir   = File.dirname(File.expand_path __FILE__)
    Unified_IO::Remote::Dir.new(dir, @localhost).permissions
    .should == `stat -c "%a" #{dir} `.strip
  end

  it 'must raise Not_Found if dir does not exist' do
    
    m = lambda { 
     Unified_IO::Remote::Dir.new("/permi", @localhost)
     .permissions
    }.should.raise(Unified_IO::Remote::Dir::Not_Found)
    .message
    
    m.should.match %r!Remote dir, "?/permi"?, must exist!
  end

end # === Remote::Dir :permissions

describe "Remote::Dir :human_perms" do
  
  behaves_like 'SSH to local'
  
  it 'must return permissions in human readable format' do
    dir   = File.dirname(File.expand_path __FILE__)
    Unified_IO::Remote::Dir.new(dir, @localhost).human_perms
    .should == `stat -c "%A" #{dir} `.strip
  end

  it 'must raise Not_Found if dir does not exist' do
    
    m = lambda { 
     Unified_IO::Remote::Dir.new("/human", @localhost)
     .human_perms
    }.should.raise(Unified_IO::Remote::Dir::Not_Found)
    .message
    
    m.should.match %r!Remote dir, "?/human"?, must exist!
  end

end # === Remote::Dir :human_perms

