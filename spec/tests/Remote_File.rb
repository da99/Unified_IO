
describe "Remote::File.new" do
  
  it 'must not expand the path' do
    Unified_IO::Remote::File.new('~/.bashrc').address
    .should.be == '~/.bashrc'
  end

end # === describe Remote::File.new

describe "Remote::File :exist!" do
  
  it 'must raise an error if file! does not exist' do
    new_mock('ssh')
      .expects(:as_method)
      .with(" [[ -f /xfile ]] && echo 'ok' ", :exits => [0,1])
      .returns("")
      
    lambda { 
     Unified_IO::Remote::File.new("/xfile").exists!
    }.should.raise(Checked::Demand::Failed)
    .message.should.match %r!Far file, "/xfile", must exist\.!
  end

end # === describe file!
