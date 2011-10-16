
BOX.create_dir  "Twins/Local"

BOX.create_dir  "Twins/Remote"

shared 'File Twins' do
  before {
    @twins = Unified_IO::File_Twins
    @local_dir  = BOX.path("Twins/Local")
    @local_file = BOX.path("Twins/Local/local.txt")
    
    @remote_dir = BOX.path("Twins/Remote")
    @remote_file = BOX.path("Twins/Remote/remote.txt")
  }
end

describe "File_Twins :new" do
  
  behaves_like 'File Twins'

  it 'inits a local file' do
    twins = @twins.new('/tmp/down', '/tmp/up')
    twins.local.class.should.be == Unified_IO::Local::File
  end
  
  it 'inits a remote file' do
    twins = @twins.new('/tmp/down', '/tmp/up')
    twins.remote.class.should.be == Unified_IO::Remote::File
  end
  
end # === describe File_Twins :new


describe "File_Twins :upload" do
  
  behaves_like 'File Twins'
  
  it 'uploads a local file to server' do
    local = BOX.create_file "Twins/Local/local.txt", 'Local content'
    remote = BOX.path('Twins/Remote/uploaded.txt')
    twin = @twins.new(local, remote)
    twin.upload
    File.read(remote).should.be == "Local content"
  end
  
end # === describe File_Twins :upload



describe "File_Twins :download" do
  
  behaves_like 'File Twins'
  
  it 'downloads a local file' do
    local = BOX.path("Twins/Local/downloaded.txt")
    remote = BOX.create_file "Twins/Remote/remote.txt", 'Remote content'
    twin = @twins.new(local, remote)
    twin.download
    File.read(local).should.be == 'Remote content'
  end
  
end # === describe File_Twins :download


