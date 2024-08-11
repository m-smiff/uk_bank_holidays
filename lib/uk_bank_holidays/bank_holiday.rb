# frozen_string_literal: true

module UKBankHolidays
  class BankHoliday
    include Comparable

    attr_reader :division, :title, :notes, :bunting
    alias bunting? bunting

    def initialize(date:, division:, title:, notes: nil, bunting: false)
      @date = date.to_date
      @division = division
      @title = title
      @notes = notes.presence
      @bunting = bunting || false
    end

    def to_s
      "#{@date.inspect}: #{title}"
    end

    def inspect
      to_s
    end

    def to_date
      @date.dup
    end

    def next
      @date.next_bank_holiday
    end

    def prev
      @date.prev_bank_holiday
    end

    def <=>(other)
      @date <=> other.to_date
    end

    def hash
      @date.hash
    end

    def ==(other)
      hash == other.hash
    end
    alias eql? ==
  end
end
