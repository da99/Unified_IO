
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

  it 'must raise an error if file! does not exist' do
    @connect.call
    
    m = lambda { 
     Unified_IO::Remote::File.new("/xfile").exists!
    }.should.raise(Checked::Demand::Failed)
    .message
    
    m.should.match %r!Remote file, !
    m.should.match %r!/xfile!
    m.should.match %r!exists\?!
  end

end # === describe file!
