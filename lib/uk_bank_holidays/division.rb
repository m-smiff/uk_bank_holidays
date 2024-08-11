# frozen_string_literal: true

require_relative 'errors/unrecognised_division'

module UKBankHolidays
  class Division
    ALL_NAMES = {
      'england-and-wales' => %w[england wales eng wal england_and_wales england_wales],
      'scotland' => %w[scot],
      'northern-ireland' => %w[ni northern_ireland]
    }.freeze

    def initialize(name)
      @name = self.class.parse_name(name)
      raise UnrecognisedDivision, "#{name} cannot be parsed as being one of #{ALL_NAMES.keys.join(', ')}" unless @name
    end

    class << self
      # Attempt to turn param in to a valid division name (in ALL_NAMES)
      def parse_name(name)
        ALL_NAMES.find { |n, acceptable| n == name.to_s || name.to_s.in?(acceptable) }&.first
      end

      def all
        ALL_NAMES.keys.map { |n| new(n) }
      end
    end

    def to_s
      @name
    end

    def to_sym
      to_s.to_sym
    end

    def inspect
      to_s
    end

    def hash
      @name.hash
    end

    def ==(other)
      hash == other.hash
    end
    alias eql? ==

    def bank_holidays(constraint = nil)
      UKBankHolidays.for_division(self) { UKBankHolidays.select_bank_holidays(constraint) }
    end
  end
end
