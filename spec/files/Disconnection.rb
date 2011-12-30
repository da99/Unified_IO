
require 'Unified_IO'
Unified_IO::Local::Shell.quiet

ssh = Unified_IO::Remote::SSH
puts "same" if !!ssh.connection === ssh.connected?


localhost = Unified_IO::Remote::Server.new(
  :hostname=> `hostname`.strip,
  :group => 'None',
  :user=>File.basename(File.expand_path '~/')
) 

ssh.connect(localhost)

puts "same" if !ssh.connection.closed? === ssh.connected?

ssh.disconnect

puts "same" if ssh.connected? === false && !ssh.connection
