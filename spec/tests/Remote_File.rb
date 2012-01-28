
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
