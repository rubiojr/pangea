module Pangea
  module Memoizers

    def self.strategy=(mod)
      puts "using memoizing strategy #{mod}"
      @strategy = mod
    end

    def self.strategy
      @strategy || Pangea::Memoizers::TimedMemoizer
    end

  end
end
