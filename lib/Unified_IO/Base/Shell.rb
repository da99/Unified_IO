
module Unified_IO
  module Base
    module Shell
      
    # ======== Permissions

    # Returns: Permissions_Array: %w! drwxr-xr-x user group !
    def permissions raw_path
      path      = expand_path(raw_path)
      dir       = File.dirname(path.strip)
      base_name = File.basename(path)
      pattern   = %r!\d+:\d+\s#{base_name}(\s|$)!
      raise "Invalid character in path: #{dir}" if dir[/\s/]
      
      results   = run( %! ls -al #{dir} ! ).split("\n").grep(pattern)

      raise "Too many ls listings for #{raw_path}: #{results.inspect}" if results.size > 1
      raise "No ls listings for #{raw_path}: #{results.inspect}" if results.size != 1

      pieces = results.first.split
			Permissions_Array.new( pieces[0], pieces[2], pieces[3] )
    end

    # Delete user and all their files.
    def delete_user name
      run "userdel -r #{name}"
    end

		def new_data_user name
			%x" id #{name} "
			shell = "/usr/sbin/nologin"
			if $?.exitstatus == 1
				run "useradd --system -s #{shell} #{name} "
			else
				run " chsh -s #{shell} #{name} "
			end
		end

    # "List ports that are taken."
    def list_used_ports 
      run %! netstat -lnptu !
    end # === namespace
    
    def quiet_io
      old_out = $stdout
      old_err = $stderr
      $stdout = StringIO.new
      $stderr = StringIO.new

      begin
        yield 
      ensure
        $stdout = old_out
        $stderr = old_err
      end
    end
    
  end # === module




    end # === module Shell
  end # === module Base
end # === module Unified_IO
