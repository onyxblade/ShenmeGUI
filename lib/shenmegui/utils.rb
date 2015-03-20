module ShenmeGUI
  class HookedArray < Array 
    
    @unhook_methods = %i{<< []= clear collect! compact! concat delete delete_at delete_if fill flatten! replace insert keep_if map map! pop push reject! replace rotate! select! shift shuffle! slice! sort! sort_by! uniq! unshift}
    @unhook_methods = Hash[@unhook_methods.collect{|x| [x, Array.instance_method(x)]}]

    def initialize(arr, owner)
      @owner = owner
      super(arr)
    end
    
    @unhook_methods.each do |k, v|
      define_method(k) do |*arr, &block|
        result = v.bind(self).call(*arr, &block)
        @owner.sync
        result
      end
    end

  end

  class HookedString < String
    @unhook_methods = %i{<< []= capitalize! chomp! chop! clear concat delete! downcase! encode! force_encoding gsub! insert lstrip! succ! next! prepend replace reverse! rstrip! slice! squeeze! strip! sub! swapcase! tr! tr_s! upcase!}
    @unhook_methods = Hash[@unhook_methods.collect{|x| [x, String.instance_method(x)]}]
    
    def initialize(str, owner)
      @owner = owner
      super(str)
    end

    @unhook_methods.each do |k, v|
      define_method(k) do |*arr, &block|
        result = v.bind(self).call(*arr, &block)
        @owner.sync
        result
      end
    end

  end

  class HookedHash < Hash
    @unhook_methods = %i{[]= clear delete delete_if keep_if merge! update rehash reject! replace select! shift}
    @unhook_methods = Hash[@unhook_methods.collect{|x| [x, Hash.instance_method(x)]}]

    def initialize(hsh, owner)
      @owner = owner
      super(hsh)
    end

    @unhook_methods.each do |k, v|
      define_method(k) do |*arr, &block|
        result = v.bind(self).call(*arr, &block)
        @owner.sync
        result
      end
    end

  end
end