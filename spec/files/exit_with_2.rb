require 'open3'

if ARGV == %w{ EXIT 127 }
  puts "Exiting"
  exit 2
end

if ARGV == ['SSH']

  require 'Unified_IO'
  Unified_IO::Local::Shell.quiet
  
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
      ssh_exec("ruby #{File.expand_path __FILE__} EXIT 127")
    end
    
  end # === class Box
  
  begin
    result = Box.new.run
  rescue Unified_IO::Remote::SSH::Exit_Error => e
    puts e.result.data
    puts *(e.result.error)
    puts e.result.exit_status.to_s
  end
  
  exit 0
end

Open3.popen3("bundle exec ruby spec/files/exit_with_2.rb SSH") do |i, o, e, w|
  print o.read
  print e.read
end

