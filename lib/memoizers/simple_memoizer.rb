module Pangea
  module Memoizers
    #
    # based on http://github.com/JackDanger/simple_memoize
    #
    module SimpleMemoizer
      def memoize(method_name, p={})
        method_name = method_name.to_s
        stripped_method_name = method_name.sub(/([!?])$/, '')

        punctuation = $1
        wordy_punctuation = (punctuation == '!' ? '_bang' : '_huh') if punctuation
        ivar_name = "@#{stripped_method_name}#{wordy_punctuation}"

        memoized_method_name = "#{stripped_method_name}_with_timed_memo#{punctuation}"
        regular_method_name  = "#{stripped_method_name}_without_memo#{punctuation}"

        unless (instance_methods + private_instance_methods).include?(method_name)
          raise NoMethodError, "The Method '#{method_name}' cannot be memoized because it doesn't exist in #{self}"
        end
        return if self.method_defined?(memoized_method_name)
    
        self.class_eval "
          def #{memoized_method_name}(*args)
            if defined?(#{ivar_name})
              puts 'memoized value'
              #{ivar_name}
            else
              #{ivar_name} = #{regular_method_name}(*args)
            end
          end
          alias_method :#{regular_method_name}, :#{method_name}
          alias_method :#{method_name}, :#{memoized_method_name}

          protected :#{method_name} if protected_instance_methods.include?('#{regular_method_name}')
          private   :#{method_name} if private_instance_methods.include?('#{regular_method_name}')
        "
      end
    end
  end
end
