require "Checked"

module Unified_IO
  module Base
    module File_System_Object

      include Checked::DSL::Racked

      private
      attr_writer :address
      
      public
      attr_reader :address

      def initialize addr
        self.address = File_Path!(addr)
      end

      def english_name
        @english_name ||= begin
                            name = self.class.name
                            .sub('Unified_IO::', '')
                            .downcase
                            .gsub('::', ' ')
                            .capitalize
                            .gsub('_', ' ') 
                          "#{name}, #{address.inspect}"
                          end
      end

      def not_exists!
        Var!( english_name, self ).not_be! :exists?
        true
      end

      def exists!
        raise self.class::Not_Found, "#{english_name}, must exist." unless exists?
        true
      end


      def expand_path
        ::File.expand_path address
      end
      
      def remote?
        !local?
      end
      
      def local?
        @is_local ||= begin
                        klass_name = self.class.name.to_s
                        if klass_name['::Local::']
                          true
                        elsif klass_name['::Remote::']
                          false
                        else
                          raise "Could not figure out location type: #{klass_name}"
                        end
                      end
      end
      def human_perms
        exists_or_raise { 
          run "stat -c %A #{address}" 
        }
      end


      # 
      # Quick lesson on getting permissions:
      #
      #   puts sprintf("#{path} %o", File.stat(path).mode )
      #   puts sprintf("#{path} %o", File.stat(path).mode & 0777 )
      #   
      #   require 'net/sftp'
      #   Net::SFTP.start('HOSTNAME', 'user', :password => nil) do |sftp|
      #     puts sprintf("%o", sftp.lstat!(path).permissions )
      #   end
      #   
      def permissions
        exists_or_raise { 
          run "stat -c %a #{address}" 
        }
      end

      def run *args
        raise ArgumentError, "No block allowed." if block_given?
        local? ? shell_run(*args) : ssh_run(*args)
      end

      private # ============================================

      def exists_or_raise
        begin
          yield
        rescue Unified_IO::Local::Shell::Failed => e
          exists!
          raise e
        end
      end

    end # === module File_System_Object
  end # === module Base
end # === module Unified_IO
