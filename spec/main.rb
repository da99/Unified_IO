
require File.expand_path('spec/helper')
require 'Unified_IO'
require 'Bacon_Colored'
require 'Bacon_FS'

require 'rake/dsl_definition'
require 'rake'
require "mocha-on-bacon"

class Ghost_Box

  module DSL
    def ghost *args, &blok
      Ghost_Box.new(*args, &blok)
    end
  end
  
  module Base
    
    include Rake::DSL
    
    attr_reader :tmp_dir
    
    def initialize
      @tmp_dir  = '/tmp/Delete_Me'
    end # === def tmp_dir
  
    def path name
      ::File.expand_path ::File.join( tmp_dir, name )
    end

    def create_all
      shell "mkdir -p #{tmp_dir}"
    end
    
    def delete_all
      shell "rm -rf #{tmp_dir} "
    end
    
    def create_dir dir
      shell "mkdir -p #{path dir}"
      path dir
    end
    
    def create_file name, content = 'No content.'
      File.open(path(name), 'w') { |io|
        io.write content
      }
      
      path name
    end
    
    def create_random_file
      name = "file_#{rand(1000)}.txt"
      create_file name
      path name
    end
    
    def shell cmd
      old_out = $stdout
      old_err = $stderr
      $stdout = StringIO.new
      $stderr = StringIO.new

      begin
        sh cmd
      ensure
        $stdout = old_out
        $stderr = old_err
      end
    end
    
    def bundle cmd
      `bundle exec #{cmd} 2>&1`.strip
    end
    
  end # === module Base
  
  include Base
  
end # === class Ghost_Box

BOX = Ghost_Box.new
BOX.create_all

FOLDER = BOX.tmp_dir
FILE   = "#{FOLDER}/file.txt"
BOX.shell %! touch #{FILE} !

at_exit {
  BOX.delete_all
}


MOCKERS = []

def new_mock name
  m = mock(name)
  MOCKERS << m
  m
end
# 
# def ssh *args, &blok
#   m = MOCKERS.shift
#   raise "No mocks left." unless m
#   if !args.empty? || blok
#     m.send(:as_method, *args, &blok)
#   else
#     m
#   end
# end

localhost = Unified_IO::Remote::Server.new(
  :hostname=>'localhost', 
  :group => 'None',
  :user=>File.basename(File.expand_path '~/')
) 
Unified_IO::Remote::SSH.connect( localhost )


Dir.glob('spec/tests/*.rb').each { |file|
  require ::File.expand_path(file.sub('.rb', '')) if ::File.file?(file)
}


__END__


shared( "OS mock" ) { 
  
  before do
    raise "Mocks left from previous test." if not MOCKERS.empty?
  end
  
}

