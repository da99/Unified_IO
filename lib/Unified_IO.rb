require "Unified_IO/version"
 
require "Unified_IO/Server"

%w{ Base Local Remote }.each { |dir|
  Dir.glob(File.join ::File.dirname(__FILE__), "Unified_IO/#{dir}/*.rb").each { |path|
    require "Unified_IO/#{dir}/#{File.basename(path).sub('.rb', '')}"
  }
}


module Unified_IO
  # Your code goes here...
end
