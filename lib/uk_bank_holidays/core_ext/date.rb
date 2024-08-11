# frozen_string_literal: true

require_relative '../bank_holidayable'

class Date
  include UKBankHolidays::BankHolidayable
end
