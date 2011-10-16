require 'Checked'
require 'Checked/Demand'

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
  
  it 'must raise an error if it does not exist' do
    lambda {
      Unified_IO::Local::Dir.new("/xbox").exists!
    }.should.raise(Checked::Demand::Failed)
    .message.should.match %r!Local dir, "?/xbox"?, must exist.!
  end

end # === describe dir!

describe "Local::Dir :exists?" do
  
  it 'must return true for a directory' do
    Unified_IO::Local::Dir.new(BOX.tmp_dir).exists?.should.be == true
  end

end # === describe Detecting a dir:
