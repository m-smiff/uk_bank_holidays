# frozen_string_literal: true

module UKBankHolidays
  module BankHolidayable
    def bank_holiday?
      !!to_bank_holiday
    end

    def next_bank_holiday
      UKBankHolidays.select_bank_holidays(to_date.tomorrow..).min
    end

    def prev_bank_holiday
      UKBankHolidays.select_bank_holidays(..to_date.yesterday).max
    end

    def to_bank_holiday
      UKBankHolidays.find_bank_holiday(to_date)
    end
  end
end
