

# require 'rake/dsl_definition'
# require 'rake'


class File_Raker
  
  module DSL
    
    # include Rake::DSL
    
    def dot_slash *strs
      source = caller[0].split(':').first
      raise "File does not exist: #{source}" unless ::File.exist?(source)
      ::File.expand_path( ::File.join ::File.dirname(source), *strs )
    end

    def top_slash *strs
      i = 0
      current = ::File.dirname(::File.expand_path(__FILE__))
      target = nil
      begin
        if dir?(::File.join( current, 'DEV')) && dir?(::File.join(current, 'PROD'))
          target = current
        else
          current = ::File.expand_path(::File.join(current, '/..'))
        end
        i += 1
      end while target.nil? && i < 4

      raise "Top directory not found: #{::File.expand_path('.')}" unless target

      ::File.expand_path( ::File.join( target, *strs ) )
    end
    
    # ======== Require

    def require_all_in dir
      names = []
      Dir.glob(::File.join dir, '*.rb').each { |file|
        names << file.sub(/\.rb$/, '' )
        require names.last
      }
      names
    end


    # ======== Permissions

    def root_owner dir, group = nil, args = '-R'
      new_owner dir, 'root', group, args
    end

    def world_readable_dir dir, args = '-R'
      sh "sudo chmod #{args} a=r #{dir}"

      sh "sudo chmod #{args} a+X #{dir}"
    end

    def new_owner dir, user, group = nil, args = '-R'
      group ||= user
      sh "sudo chown #{args} #{user}:#{group} #{dir}"
    end


    # ======== File Reading

    def list_files dir
      Dir.glob(::File.join(dir, '*'))
    end


    # ======== File Writing

    def prepend_to_file raw_file, &blok
      write_to_file :top, raw_file, &blok
    end

    # def append_to_all_files dir, msg
    #   list_files(dir).each { |file|
    #     append_to_file( file ) do |contents, io|
    #       io.write msg
    #     end
    #   }
    # end

    # def append_to_file raw_file, &blok
    #   write_to_file :bottom, raw_file, &blok
    # end

    def new_file raw_file, contents
      file = ::File.expand_path(raw_file)
      raise "File already exists: #{file}" if ::File.exists?(file)
      ::File.open( file, 'w' ) { |io|
        io.write contents
      }
    end

    # For modes, see http://www.ruby-doc.org/core/classes/IO.html
    def write_to_file pos = :top, raw_file, &blok
      backup_file raw_file

      file = ::File.expand_path(raw_file)
      mode = case pos
             when :top
             when :bottom
             else
               raise "Position can only be :top or :bottom: #{pos.inspect}"
             end

      contents = ::File.read(file)

      ::File.open( file , "w") { |io|
        io.write( "#{contents}\n" )if pos == :bottom
        blok.call(contents, io)
        io.write( "#{contents}" ) if pos == :top
      }
    end

    def backup_or_restore_original raw_file
      file     = ::File.expand_path(raw_file)
      original = original_path( file )

      if file? original
        backup_file file, :mv
        sh "cp #{original} #{file}"
      else
        backup_file file
      end

    end

    def backup_file raw_file, op = :cp
      file = ::File.expand_path(raw_file)
      orig     = original_path( file )
      backup   = backup_path( file )
      new_file = (file? orig) ? backup : orig

      if not [:cp, :mv].include?(op)
        raise "Invalid file operation: #{op.inspect}" 
      end

      folder = backup_dir(file, true)
      unless ::File.directory?(folder)
        sh "mkdir #{folder}"
      end

      sh "#{op.to_s} #{file} #{ new_file }"
    end

    def original_path file
      backup_dir( "#{file}.original")
    end

    def backup_path file = nil
      backup_dir( "#{file}.original.#{Time.now.to_i}")
    end

    def backup_dir raw_file, just_dir = false
      name = '.Unified_IO_backup'

      file        = ::File.expand_path(raw_file)
      dir         = ::File.dirname(file)
      file_name   = ::File.basename(file)
      backup_file = ::File.join(dir, name, file_name)

      if just_dir
        ::File.dirname(backup_file)
      else
        backup_file
      end
    end

    def file? str
      ::File.file?(::File.expand_path str)
    end

    def file! str
      file?(str) ||
      raise( "Unknown file: #{str}" )
    end

    def dir? str
      Dir.exists?(::File.expand_path str)
    end

    def dir! str
      dir?(str) ||
      raise("Unknown dir: #{str}")
    end

    def upload_file source, dest

      raise "File does not exist: #{source.inspect}" unless file?(source)

      raise "Destination must be a string: #{dest.inspect}" if not dest.is_a?(String)
      dest = dest.strip
      raise "Destination can't be empty." if dest.empty?

      use_scp "-P #{DEPLOYER.host_port} #{source} #{fetch :ssh_user}@#{DEPLOYER.host_address}:#{dest}"
      puts ""
    end

  end # === module Mod
  
end # === module File_Raker
