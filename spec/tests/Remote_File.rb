
describe "Remote::File.new" do
  
  it 'must return true for remote?' do
    Unified_IO::Remote::File.new('~/bashee').remote?.should.be == true
  end
  
  it 'must not expand the path' do
    Unified_IO::Remote::File.new('~/.bashrc').address
    .should.be == File.expand_path('~/.bashrc')
  end

end # === describe Remote::File.new

describe "Remote::File :exist!" do
  
  behaves_like 'SSH to local'

  it 'must raise Not_Found if file does not exist' do
    
    m = lambda { 
     f = Unified_IO::Remote::File.new("/xfile")
     f.server = @localhost
     f.exists!
    }.should.raise(Unified_IO::Remote::File::Not_Found)
    .message
    
    m.should.match %r!Remote file, "?/xfile"?, must exist!
  end

end # === describe file!

describe "Remote::File :permissions" do
  
  behaves_like 'SSH to local'
  
  it 'must return permissions as an octal string' do
    file   = File.expand_path __FILE__
    Unified_IO::Remote::File.new(file, @localhost).permissions
    .should == `stat -c "%a" #{file} `.strip
  end

  it 'must raise Not_Found if file does not exist' do
    
    m = lambda { 
     Unified_IO::Remote::File.new("/permi", @localhost)
     .permissions
    }.should.raise(Unified_IO::Remote::File::Not_Found)
    .message
    
    m.should.match %r!Remote file, "?/permi"?, must exist!
  end

end # === Remote::File :permissions

describe "Remote::File :human_perms" do
  
  behaves_like 'SSH to local'
  
  it 'must return permissions in human readable format' do
    file   = File.expand_path __FILE__
    Unified_IO::Remote::File.new(file, @localhost).human_perms
    .should == `stat -c "%A" #{file} `.strip
  end

  it 'must raise Not_Found if file does not exist' do
    
    m = lambda { 
     Unified_IO::Remote::File.new("human", @localhost)
     .human_perms
    }.should.raise(Unified_IO::Remote::File::Not_Found)
    .message
    
    m.should.match %r!Remote file, "?human"?, must exist!
  end

end # === Remote::File :human_perms









