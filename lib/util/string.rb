module Pangea
  module Util

    def self.humanize_bytes(bytes)
      m = bytes.to_i
      units = %w[Bits Bytes MB GB TB PB]
      while (m/1024.0) >= 1 
        m = m/1024.0
        units.shift
      end
      return m.round.to_s + " #{units[0]}"
    end

  end
end
