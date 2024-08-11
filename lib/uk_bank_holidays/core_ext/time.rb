# frozen_string_literal: true

require_relative '../bank_holidayable'

class Time
  include UKBankHolidays::BankHolidayable
end
