
describe "Local::File.new" do
  
  it 'must return true for local?' do
    Unified_IO::Local::File.new('~/.bashrc').local?.should.be == true
  end

  it 'must raise error if address is a directory' do
    addr = File.expand_path '~/'
    lambda { Unified_IO::Local::File.new('~/') }
    .should.raise(Checked::Demand::Failed)
    .message
    .should.match %r!Local file, "#{addr}", can't.+directory.!
  end
  
  it 'must expand the path' do
    Unified_IO::Local::File.new('~/.bashrc').address
    .should.be == File.expand_path('~/.bashrc')
  end
  
  it 'raises error if path has control chars' do
    lambda { 
      d = Unified_IO::Local::File.new("~/\t.bashrc")
    }.should.raise(Checked::Demand::Failed)
    .message.should.match %r!invalid characters!
  end

end # === describe Local::File.new

describe "Local::File :exist!" do
  
  it 'must raise an error if file! does not exist' do
    lambda { 
      Unified_IO::Local::File.new("/xfile").exists!
    }.should.raise(Checked::Demand::Failed)
    .message.should.match %r!Local file, .?/xfile.?,.+, must be: exists\?!
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

  it "must raise error if file exists." do
    old = BOX.create_random_file
    lambda {
      Unified_IO::Local::File.new(old).create "some content"
    }
    .should.raise(Checked::Demand::Failed)
    .message
    .should.match %r!Local file, .?#{old}.?,.+, must not be: exists\?!
      
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

