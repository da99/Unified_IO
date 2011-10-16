require 'Checked/Demand'
require "Unified_IO/Base/File_System_Object"

module Unified_IO

  module Local

    class Dir

      module Base

        include Checked::Demand::DSL
        include ::Unified_IO::Base::File_System_Object
        include ::Unified_IO::Local::Shell::DSL

        File_Not_Found = Class.new(RuntimeError)
        Too_Many_Files = Class.new(RuntimeError)

        public # ==============================

        def initialize addr
          super(::File.expand_path(demand! addr, :file_address!))
          named_demand! 'Local file', self.address, :not_file!
        end

        def english_name
          "Local dir, #{address},"
        end

        def exists?
          ::Dir.exists?(address)
        end

        def files 
          visibles + hiddens
        end

        def visibles
          Local::File.filter Dir.glob(::File.join( address, '*' ))
        end

        def hiddens
          Local::File.filter Dir.glob(::File.join( address, '.*' ), ::File::FNM_DOTMATCH)
        end 

        def content? str
          begin
            content_address str
            true
          rescue File_Not_Found => e
            false
          end
        end

        def content_address str
          found = files.select { |file|
            file.content_same_as_as?( str )
          }

          err_msg = "with content: #{str[0..20]}..."

          case found.size
          when 0
            raise File_Not_Found, err_msg
          when 1
            found
          else
            raise Too_Many_Files, err_msg
          end
        end

        def content_in_any? content, *dirs
          found = dirs.flatten.detect { |raw_d|
            name = demand!(raw_d.to_s, :dir_address!)
            Local::Dir.new(::File.join address, name).content?(content)
          }

          !!found
        end

        def dot_slash *strs
          source = caller[0].split(':').first
          raise "File does not exist: #{source}" unless File.exists?(source)
          expand_path( File.join File.dirname(source), *strs )
        end
        
        def top_slash *strs

          i = 0
          current = dot_slash
          target = nil
          begin
            if %w{ Gemfile lib spec }.detect { |dir| File.exists?(File.join current, dir) }
              target = current
            else
              current = File.expand_path(File.join(current, '/..'))
            end
            i += 1
          end while target.nil? && i < 4

          raise "Top directory not found: #{File.expand_path('.')}" unless target

          File.expand_path( File.join( target, *strs ) )
        end
        
        # ======== File Reading

        def require_all
          prevent_remotely

          names = []
          list_files('*.rb').each { |file|
            req = file.sub( /\.rb$/, '')
            names << File.basename(req)
            require req
          }
          names
        end

        def list_files glob = '*'
          Dir.glob(File.join(address, glob)).select { |file|
            File.file? file
          }
        end
        
        def ruby_class_names
          list_files('*.rb').map { |file|
            File.basename(file).sub(/\.rb$/, '' )
          }
        end
        
        # ======== Permissions
        
        def root_owner group = nil, args = '-R'
          new_owner address, 'root', group, args
        end

        def world_readable args = '-R'
          shell "sudo chmod #{args} a=r #{address}"
          shell "sudo chmod #{args} a+X #{address}"
        end
        
        def new_owner user, group = nil, args = '-R'
          group ||= user
          sh "sudo chown #{args} #{user}:#{group} #{address}"
        end
        
        # ======== File Writing

        def append_to_files msg
          dir = address
          list_files(dir).each { |file|
            if File.file?(file)
              append_to_file( file ) do |contents, io|
                io.write msg
              end
            end
          }
        end



        
      end # === module Base

      include Base

    end # === class Dir
    
  end # === class Local
  
end # === module Unified_IO
