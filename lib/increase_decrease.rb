module Waterflowseast
  module IncreaseDecrease
    def increase!(column, count = 1)
      self.class.update_counters(id, column => count)
    end

    def increase_reload!(column, count = 1)
      increase!(column, count)
      reload
    end

    def decrease!(column, count = 1)
      self.class.update_counters(id, column => - count)
    end

    def decrease_reload!(column, count = 1)
      decrease!(column, count)
      reload
    end
  end
end
