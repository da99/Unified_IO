require 'open3'


if ARGV == ['PTY']

  require 'Unified_IO'
  Unified_IO::Local::Shell.loud
  
  class Box

    include Unified_IO::Remote::SSH::DSL

    def initialize
      server Unified_IO::Remote::Server.new(
        :hostname=>`hostname`.strip,
        :group => 'Local',
        :user  => `whoami`.strip
      )
    end
    
    def run
      ssh_exec("sudo uptime")
    end
    
  end # === class Box
  
  result = Box.new.run
  exit
end


Open3.popen3("bundle exec ruby spec/files/run_pty.rb PTY") do |i, o, e, w|

  sleep 2
  i.puts 'a'
  puts o.gets
  puts o.gets
  Process.kill 'INT', w[:pid]
end
