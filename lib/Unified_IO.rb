require "Unified_IO/version"
require 'Checked'
require 'Get_Set'

%w{ Base Local Remote }.each { |dir|
  Dir.glob(File.join ::File.dirname(__FILE__), "Unified_IO/#{dir}/*.rb").sort.reverse.each { |path|
    require "Unified_IO/#{dir}/#{File.basename(path).sub('.rb', '')}"
  }
}

require "Unified_IO/File_Twins"

module Unified_IO
  # Your code goes here...
end
