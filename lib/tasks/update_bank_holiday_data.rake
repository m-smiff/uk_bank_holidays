# frozen_string_literal: true

require_relative '../uk_bank_holidays'

desc 'Receives GOV UK Data and writes to the repository JSON file'
task update_bank_holidays_data: :check_bank_holiday_data_validity do
  next unless @response && @out_of_date

  puts "Writing JSON data to `#{UKBankHolidays::DATA_SOURCE_PATH}`..."
  File.write(UKBankHolidays::DATA_SOURCE_PATH, @response.body)
  puts 'Done!'
end
