require 'Unified_IO'

localhost = Unified_IO::Remote::Server.new(
  :hostname=>`hostname`.strip, 
  :group => 'None',
  :user=>File.basename(File.expand_path '~/')
) 

Unified_IO::Remote::SSH.connect( localhost )
Unified_IO::Remote::SSH.disconnect

bdrm = Unified_IO::Remote::Server.new(
  :hostname=>`hostname`.strip, 
  :group => 'None',
  :user=>File.basename(File.expand_path '~/')
) 

Unified_IO::Remote::SSH.connect( bdrm )
Unified_IO::Remote::SSH.disconnect

at_exit {
  puts("opened/closed all") unless Unified_IO::Remote::SSH.connected?
}
