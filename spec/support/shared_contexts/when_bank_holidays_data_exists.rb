# frozen_string_literal: true

RSpec.shared_context 'when bank holidays data exists' do
  let(:data) do
    {
      'england-and-wales' => {
        'division' => 'england-and-wales',
        'events' => [
          { date: '2018-01-01', title: 'New Year\s Day', notes: '', bunting: false },
          { date: '2019-08-28', title: 'Wicked Party Day', notes: '', bunting: false },
          { date: '2019-12-25', title: 'Wassssup', notes: '', bunting: true },
          { date: '2020-03-02', title: 'Only England and Wales Babe', notes: 'Wow, notes!', bunting: false }
        ]
      },
      'scotland' => {
        'division' => 'scotland',
        'events' => [
          { date: '2018-01-01', title: 'New Year\s Day', notes: '', bunting: true },
          { date: '2018-04-22', title: 'Be Cool Day', notes: '', bunting: true },
          { date: '2019-03-02', title: 'Haggis and Square Sausage Day', notes: 'Lets eat', bunting: false },
          { date: '2019-08-28', title: 'Wicked Party Day', notes: '', bunting: false },
          { date: '2019-12-25', title: 'Wassssup', notes: '', bunting: false }
        ]
      },
      'northern-ireland' => {
        'division' => 'northern-ireland',
        'events' => [
          { date: '2018-01-01', title: 'New Year\s Day', notes: '', bunting: false },
          { date: '2018-03-02', title: 'Belfast Bonanza', notes: 'Lets party', bunting: false },
          { date: '2018-04-22', title: 'Be Cool Day', notes: '', bunting: true },
          { date: '2018-04-23', title: 'Be Cooler Day', notes: 'So cool', bunting: false },
          { date: '2019-08-28', title: 'Wicked Party Day', notes: '', bunting: true },
          { date: '2019-12-25', title: 'Wassssup', notes: '', bunting: true }
        ]
      }
    }
  end

  let(:returned_data) { data }

  before do
    allow(File).to receive(:read).with(UKBankHolidays::DATA_SOURCE_PATH).and_return(returned_data)
  end

  after { allow(File).to receive(:read).with(UKBankHolidays::DATA_SOURCE_PATH).and_call_original }
end
