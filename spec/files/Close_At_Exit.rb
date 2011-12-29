require 'Unified_IO'

localhost = Unified_IO::Remote::Server.new(
  :hostname=>'localhost', 
  :group => 'None',
  :user=>File.basename(File.expand_path '~/')
) 

Unified_IO::Remote::SSH.connect(localhost)

class << Unified_IO::Remote::SSH.connection 
  alias_method :close_wo_puts, :close
  def close_and_puts
    close_wo_puts
    puts "closed"
  end
   
  alias_method :close, :close_and_puts
end


# at_exit {
#   puts("closed") if Unified_IO::Remote::SSH.connection.closed?
# }
#  at_exit { puts '1' }
#  at_exit { puts '2' }
