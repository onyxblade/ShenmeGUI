module ShenmeGUI
  @unhook_methods = {
    array: %i{<< []= clear collect! compact! concat delete delete_at delete_if fill flatten! replace insert keep_if map map! pop push reject! replace rotate! select! shift shuffle! slice! sort! sort_by! uniq! unshift},
    string: %i{<< []= capitalize! chomp! chop! clear concat delete! downcase! encode! force_encoding gsub! insert lstrip! succ! next! prepend replace reverse! rstrip! slice! squeeze! strip! sub! swapcase! tr! tr_s! upcase!},
    hash: %i{[]= clear delete delete_if keep_if merge! update rehash reject! replace select! shift}
  }
  @unhook_methods.each do |k, v|
    const_set("Hooked#{k.to_s.capitalize}", Class.new(const_get(k.to_s.capitalize)))
    const_get("Hooked#{k.to_s.capitalize}").class_eval do
      def initialize(obj, owner)
        @owner = owner
        super(obj)
      end

      methods = Hash[v.collect{|x| [x, const_get(k.to_s.capitalize).instance_method(x)]}]
      methods.each do |k, v|
        define_method(k) do |*arr, &block|
          result = v.bind(self).call(*arr, &block)
          @owner.sync
          result
        end
      end

    end
  end
end