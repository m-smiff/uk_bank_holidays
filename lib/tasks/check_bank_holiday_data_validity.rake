# frozen_string_literal: true

require_relative '../uk_bank_holidays'
require 'httparty'

desc 'Receives GOV UK Data and writes to the repository JSON file'
task :check_bank_holiday_data_validity do
  puts "Sending request to #{UKBankHolidays::GOV_UK_API_URL} to retrieve GOV UK Bank Holiday data..."
  @response = HTTParty.get(UKBankHolidays::GOV_UK_API_URL)

  next(puts "Error response received (#{@response.code}): #{@response.body}") unless @response.success?

  puts 'Success! Comparing against currently stored data...'

  @out_of_date = @response.body != File.read(UKBankHolidays::DATA_SOURCE_PATH)

  puts @out_of_date ? 'Data deemed to be out of date!' : 'Data up-to-date!'
end
