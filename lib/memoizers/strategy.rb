module Pangea
  module Memoizers
    module Strategy
      puts 'using memoizing strategy TimedMemoizer'
      include Pangea::Memoizers::TimedMemoizer
    end
  end
end
