require 'open3'

if ARGV == ['PTY']

  require 'Unified_IO'
  
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
end

Open3.popen3("bundle exec ruby spec/files/run_pty.rb PTY") do |i, o, e, w|
  
  last = ''
  while d = o.gets(' ')
    print d
    
    if "#{last}#{d}".strip == 'Your answer:'
      Process.kill "INT", w[:pid]
    end
    
    last = d
  end
  
  while d = e.gets(' ')
    print d
  end
  
end
