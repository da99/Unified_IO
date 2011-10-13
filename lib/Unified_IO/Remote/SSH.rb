require 'net/ssh'
require 'net/scp'

module Unified_IO

  class SSH

    module DSL

      def ssh *args
        run_it = !args.empty? || block_given?
        return SSH if !run_it
        raise "Not connected" if SSH.connected?

        v = SSH.new(*args)
        return(yield(v)) if block_given?

        v
      end

    end # === module DSL

    module Class_Methods

      attr_accessor :connection

      def new_do
        old = @do
        @do = new
        yield
        @do = old
      end

      def connect server
        if self.connection
          raise "
            Connection already established.
            Can not open another connection. 
          ".split.join
        end

        net_hash = Hash[:port=>server.port]
        (net_hash[:password] = server.password) if server.password

        begin
          Net::SSH.start(server.ip, server.login, net_hash) do |ssh_connection|

            self.connection = ssh_connection
            yield
            self.connection = nil

          end
        rescue Net::SSH::AuthenticationFailed => e
          shell.yell( "Connection using: " + [server.ip, server.login, net_hash].inspect )
          raise e
        end
      end

    end # === module Class_Methods

    module Base

      attr_reader :server
      def initialize new_server
        @server = new_server
      end

      def exits
      end

      def silent
      end

      def sudo
      end

      def upload here, there
        SSH.connection.scp.upload!( temp_address, address )
      end

      def run
      end

      def sudo str, *args, &blok
        return str if root_login?

        cmd = begin
                str
                .strip
                .split("\n")
                .map(&:strip)
                .reject(&:empty?)
                .map { |line| "sudo #{line}" }
                .join("\n")
              end

        ssh cmd, *args, &blok
      end

    end # === module Base

    include Base
    extend Class_Methods

  end # === class SSH

end # === module Unified_IO
