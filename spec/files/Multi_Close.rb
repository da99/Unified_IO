require 'Unified_IO'

localhost = Unified_IO::Remote::Server.new(
  :hostname=>'localhost', 
  :group => 'None',
  :user=>File.basename(File.expand_path '~/')
) 

Unified_IO::Remote::SSH.connect( localhost )
Unified_IO::Remote::SSH.disconnect
Unified_IO::Remote::SSH.disconnect
Unified_IO::Remote::SSH.disconnect
Unified_IO::Remote::SSH.disconnect

at_exit {
  puts("all closed") unless Unified_IO::Remote::SSH.connected?
}
