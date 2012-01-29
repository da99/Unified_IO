
describe "Local::File.new" do
  
  it 'must return true for local?' do
    Unified_IO::Local::File.new('~/.bashrc').local?.should.be == true
  end

  it 'must raise Not_A_File if address is a directory' do
    addr = File.expand_path '~/'
    lambda { Unified_IO::Local::File.new('~/') }
    .should.raise(Unified_IO::Local::File::Not_A_File)
    .message
    .should.match %r!Local file, "?#{addr}"?, can't.+directory.!
  end
  
  it 'must expand the path' do
    Unified_IO::Local::File.new('~/.bashrc').address
    .should.be == File.expand_path('~/.bashrc')
  end
  
  it 'raises Checked::Demand::Failed if path has control chars' do
    lambda { 
      d = Unified_IO::Local::File.new("~/\t.bashrc")
    }.should.raise(Checked::Demand::Failed)
    .message.should.match %r!invalid characters!
  end

end # === describe Local::File.new

describe "Local::File :exist!" do
  
  it 'must raise Not_Found if file! does not exist' do
    m = lambda { 
      Unified_IO::Local::File.new("/xfile").exists!
    }.should.raise(Unified_IO::Local::File::Not_Found)
    .message
    m.should.match %r!Local file, "?/xfile"?, must exist.!
  end
  

end # === describe file!


describe 'Local::File :exists?' do

  it 'must return true if it is a file' do
    Unified_IO::Local::File.new('~/.bashrc')
      .exists?.should.be == true
  end

  it 'must return false if it does not exist' do
    Unified_IO::Local::File.new(File.expand_path '~/yikes')
      .exists?.should.be == false
  end
  
end # === describe

describe "Local::File :create a new file." do

  it "must raise Overwrite_Error if file exists." do
    old = BOX.create_random_file
    lambda {
      Unified_IO::Local::File.new(old).create "some content"
    }
    .should.raise(Unified_IO::Local::File::Overwrite_Error)
    .message
    .should.match %r!Local file, .?#{old}.?, already exists!
      
  end
  
  it 'must create and write content.' do
    addr = "/tmp/create_file_#{rand(999)}.txt"
    msg = "new content #{rand(19999)}"
    
    Unified_IO::Local::File.new(addr).create msg
    File.read(addr).should.be == msg

    at_exit {
      File.delete addr
    }
  end

end # === describe

describe "Local::File :permissions" do
  
  behaves_like 'SSH to local'
  
  it 'must return permissions as an octal string' do
    file   = File.expand_path __FILE__
    Unified_IO::Local::File.new(file).permissions
    .should == `stat -c "%a" #{file} `.strip
  end

  it 'must raise Not_Found if file does not exist' do
    
    m = lambda { 
     Unified_IO::Local::File.new("/permi")
     .permissions
    }.should.raise(Unified_IO::Local::File::Not_Found)
    .message
    
    m.should.match %r!Local file, "?/permi"?, must exist!
  end

end # === Local::File :permissions

describe "Local::File :human_perms" do
  
  behaves_like 'SSH to local'
  
  it 'must return permissions in human readable format' do
    file   = File.expand_path __FILE__
    Unified_IO::Local::File.new(file).human_perms
    .should == `stat -c "%A" #{file} `.strip
  end

  it 'must raise Not_Found if file does not exist' do
    
    m = lambda { 
     Unified_IO::Local::File.new("/human")
     .human_perms
    }.should.raise(Unified_IO::Local::File::Not_Found)
    .message
    
    m.should.match %r!Local file, "?/human"?, must exist!
  end

end # === Local::File :human_perms














__END__

describe ":append_to_file" do

  it "should add text to the bottom of the file" do
    bash_shell("mkdir -p #{FOLDER}")
    txt  = "ad the bottom"
    path = "#{FOLDER}/test.txt"

    bash_shell("touch #{path}")
    box = Box.new
    rake_box { |bx|
      bx.append_to_file(path) do | contents, f |
        f.write txt
      end
    }

    File.read(path)[/#{txt}$/].should.be == txt
  end # === it

end # ===  describe



# describe "Local File :append" do
# 
#   it "should add text to the bottom of the file" do
#     content = "Wallace Thornhill"
#     trail   = "rocks!"
#     target  = [content, trail].join("\\n")
#     
#     temp = BOX.create_random_file { |io|
#       io.write content
#     }
#     
#     Unified_IO::Local::File.new(temp).append trail
# 
#     File.read(temp).should.be == target
#   end # === it
# 
# end # ===  describe

