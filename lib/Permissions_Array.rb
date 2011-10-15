
class Permissions_Array < Array
  
  module Base
    
    attr_reader :mode_bits, :owner, :group

    def initialize bits, owner, group
      super()
      @mode_bits = self[0] = bits
      @owner     = self[1] = owner
      @group     = self[2] = group
    end
    
  end # === module Base

  include Base
  
end # === class Permissions_Array

