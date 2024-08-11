# frozen_string_literal: true

module UKBankHolidays
  class Config
    attr_reader :memoize_data, :division_context, :data_source
    alias memoize_data? memoize_data

    def initialize(on_change_data_source:, default_data_source:, memoize_data:, default_division_context:)
      @on_change_data_source = on_change_data_source
      @default_data_source = default_data_source
      @data_source = default_data_source
      @memoize_data = memoize_data
      @default_division_context = default_division_context
      @division_context = default_division_context
    end

    def data_source=(source)
      raise TypeError, 'date_source must be a callable object' unless source.respond_to?(:call)

      UKBankHolidays.send(@on_change_data_source)
      @data_source = source
    end

    def default_data_source=(source)
      @default_data_source = (self.data_source = source)
    end

    def memoize_data=(value)
      UKBankHolidays.send(@on_change_data_source) if memoize_data? && !value
      @memoize_data = !!value
    end

    def division_context=(division_name)
      @division_context = Division.new(division_name)
    end

    def default_division_context=(division_name)
      @default_division_context = (self.division_context = Division.new(division_name))
    end

    def overide(attribute, value, &block)
      send(:"#{attribute}=", value)
      result = block.call
      send(:"#{attribute}=", instance_variable_get(:"@default_#{attribute}"))
      result
    end
  end
end
