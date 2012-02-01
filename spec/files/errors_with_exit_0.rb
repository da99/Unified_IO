
require 'open3'

if ARGV == %w{ EXIT 0 }
  STDERR.puts "err msg 1"
  STDERR.puts "err msg 2"
  exit 0
end

if ARGV == ['SSH']

  require 'Unified_IO'
  
  module Net; module SSH; module Connection; class Channel

    def request_pty *args
    end

  end; end; end; end

  class Box

    include Unified_IO::Remote::SSH::DSL

    def initialize
      server Unified_IO::Remote::Server.new(
        :hostname=>`hostname`.strip,
        :user  => `whoami`.strip
      )
    end
    
    def run
      ssh_exec("ruby #{File.expand_path __FILE__} EXIT 0")
    end
    
  end # === class Box
  
  result = begin
    Box.new.run
  rescue Unified_IO::Remote::SSH::Exit_Error => e
    e.result
  end
  
  puts *(result.error)
  puts "Exit: #{result.exit_status}"
    
  exit 0
end

Open3.popen3("bundle exec ruby #{__FILE__} SSH") do |i, o, e, w|
  print o.read
  print e.read
end

