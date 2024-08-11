# frozen_string_literal: true

require_relative 'uk_bank_holidays/version'

require_relative 'uk_bank_holidays/config'
require_relative 'uk_bank_holidays/bank_holiday'
require_relative 'uk_bank_holidays/division'

require_relative 'uk_bank_holidays/core_ext/date'
require_relative 'uk_bank_holidays/core_ext/time'

require 'active_support/all'

module UKBankHolidays
  DATA_SOURCE_PATH = 'lib/uk_bank_holidays.json'
  GOV_UK_API_URL = 'https://www.gov.uk/bank-holidays.json'

  DEFAULT_CONFIG_PARAMS = {
    on_change_data_source: :wipe_memoized_data,
    default_data_source: -> { File.read(DATA_SOURCE_PATH) },
    memoize_data: true,
    default_division_context: Division.new('england-and-wales')
  }.freeze

  @config = Config.new(**DEFAULT_CONFIG_PARAMS)

  class << self
    def config(&block)
      block.call(@config)
    end

    def all_division_bank_holidays
      deserialized_data[@config.division_context] || Set[]
    end

    def using_data_source(data_source, &block)
      @config.overide(:data_source, data_source) { block.call }
    end

    def for_division(division, &block)
      @config.overide(:division_context, division) { block.call }
    end

    def min
      all_division_bank_holidays.min
    end

    def max
      all_division_bank_holidays.max
    end

    def find_bank_holiday(date)
      all_division_bank_holidays.to_a.find { |bh| bh.to_date == date.to_date }
    end

    # @constraint [#include?]
    def select_bank_holidays(constraint = nil)
      return all_division_bank_holidays unless constraint

      all_division_bank_holidays.filter { |bh| bh.to_date.in? constraint }
    end

    private

    def wipe_memoized_data
      remove_instance_variable(:@deserialized_data) if defined? @deserialized_data
    end

    def deserialized_data
      if @config.memoize_data?
        @deserialized_data ||= deserialize_data
      else
        deserialize_data
      end
    end

    def deserialize_data
      data = @config.data_source.call
      data = JSON.parse(data) unless data.is_a?(Hash)
      data.transform_keys! { |k| Division.new(k) }
      data.transform_values(&method(:events_into_set))
    end

    def events_into_set(hash)
      as_bank_holidays = hash.symbolize_keys![:events].map do |e|
        BankHoliday.new(**e.symbolize_keys, division: Division.new(hash[:division]))
      end

      Set.new(as_bank_holidays.sort)
    end
  end
end
