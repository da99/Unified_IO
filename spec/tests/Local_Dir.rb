require 'Checked'

describe "Local::Dir.new" do
  
  before { @dir = Unified_IO::Local::Dir }

  it 'must be true when asked local?' do
    @dir.new('~/').local?.should.be == true  
  end

  it 'must expand the path' do
    Unified_IO::Local::Dir.new('~/').address
    .should.be == ::File.expand_path('~/')
  end

  it 'must raise an error if it is an existing file' do
    path = BOX.create_random_file
    lambda {
      d = Unified_IO::Local::Dir.new(path)
    }.should.raise(Checked::Demand::Failed)
    .message.should.match %r!Local file, "?#{path}"?, can't be a file.!
  end
  
  it 'raises error if path has control chars' do
    lambda { 
      d = Unified_IO::Local::Dir.new("~\n/")
    }.should.raise(Checked::Demand::Failed)
    .message.should.match %r!invalid characters!
  end
  
end # === describe Local::Dir.new

describe 'Local::Dir :exists!' do
  
  it 'raises Not_Found if it does not exist' do
    m = lambda {
      Unified_IO::Local::Dir.new("/vbox").exists!
    }.should.raise(Unified_IO::Local::Dir::Not_Found)
    .message
    m.should.match %r!Local dir, "?/vbox"?, must exist!
  end

end # === describe dir!

describe "Local::Dir :exists?" do
  
  it 'must return true for a directory' do
    Unified_IO::Local::Dir.new(BOX.tmp_dir).exists?.should.be == true
  end

end # === describe Detecting a dir:

describe "Local::Dir :files" do
  
  it 'must include hidden and visible files' do
    path         = File.expand_path( '.' )
    target       = Dir.glob( path + '/*', File::FNM_DOTMATCH).select { |file| File.file?(file) }
    files        = Unified_IO::Local::Dir.new( path ).files.map(&:address)
    
    files.sort.should == target.sort
  end
  
end # === describe Local::Dir :files

describe "Local::Dir :content_address" do
  
  it 'must return address of file based on content' do
    spec_main = File.expand_path('spec/main.rb')
    spec_dir  = File.dirname(spec_main)
    spec_main_contents = File.read(spec_main)
    file = Unified_IO::Local::Dir.new(spec_dir).content_address(spec_main_contents)
    file.address.should.be == spec_main
  end
  
end # === describe Local::Dir :content_addres


describe "Local::Dir :permissions" do
  
  behaves_like 'SSH to local'
  
  it 'must return permissions as an octal string' do
    dir   = File.dirname(File.expand_path __FILE__)
    Unified_IO::Local::Dir.new(dir).permissions
    .should == `stat -c "%a" #{dir} `.strip
  end

  it 'must raise Not_Found if file does not exist' do
    
    m = lambda { 
     Unified_IO::Local::Dir.new("/permi")
     .permissions
    }.should.raise(Unified_IO::Local::Dir::Not_Found)
    .message
    
    m.should.match %r!Local dir, "?/permi"?, must exist!
  end

end # === Local::Dir :permissions

describe "Local::Dir :human_perms" do
  
  behaves_like 'SSH to local'
  
  it 'must return permissions in human readable format' do
    dir = File.dirname(File.expand_path __FILE__)
    Unified_IO::Local::Dir.new(dir).human_perms
    .should == `stat -c "%A" #{dir} `.strip
  end

  it 'must raise Not_Found if dir does not exist' do
    
    m = lambda { 
     Unified_IO::Local::Dir.new("/human")
     .human_perms
    }.should.raise(Unified_IO::Local::Dir::Not_Found)
    .message
    
    m.should.match %r!Local dir, "?/human"?, must exist!
  end

end # === Local::Dir :human_perms









