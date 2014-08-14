module ActiveForce
  module Finders

    def find_by conditions
      where(conditions).limit 1
    end

  end
end
