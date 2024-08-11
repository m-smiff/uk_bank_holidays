# frozen_string_literal: true

RSpec.describe UKBankHolidays do
  describe '::VERSION' do
    it { expect(described_class::VERSION).to be_instance_of(String) }
  end

  describe '::GOV_UK_API_URL' do
    it { expect(described_class::GOV_UK_API_URL).to eq 'https://www.gov.uk/bank-holidays.json' }
  end

  describe '::DEFAULT_CONFIG_PARAMS' do
    it do
      expect(described_class::DEFAULT_CONFIG_PARAMS)
        .to include(on_change_data_source: :wipe_memoized_data,
                    memoize_data: true,
                    default_division_context: described_class::Division.new('england-and-wales'))
    end

    describe ':default_data_source' do
      before { allow(File).to receive(:read) }

      it do
        described_class::DEFAULT_CONFIG_PARAMS[:default_data_source].call
        expect(File).to have_received(:read).with('lib/uk_bank_holidays.json')
      end
    end
  end

  describe '@config' do
    it do
      expect(described_class.instance_variable_get(:@config))
        .to be_instance_of(described_class::Config)
    end
  end

  describe '::config' do
    it do
      expect { |b| described_class.config(&b) }
        .to yield_with_args(described_class.instance_variable_get(:@config))
    end
  end

  describe 'default data source' do
    let(:data) { JSON.parse(File.read(described_class::DATA_SOURCE_PATH)) }

    describe 'top-level keys' do
      it { expect(data.keys).to contain_exactly('england-and-wales', 'scotland', 'northern-ireland') }
    end

    describe 'values' do
      it { expect(data.values.map(&:keys)).to all contain_exactly('division', 'events') }
    end

    %w[england-and-wales scotland northern-ireland].each do |d|
      describe d do
        describe ':division' do
          it { expect(data[d]['division']).to eq d }
        end

        describe ':events' do
          it { expect(data[d]['events']).to be_instance_of(Array) }

          it do
            expect(data[d]['events']).to all include('date' => satisfy('date parsable', &:to_date),
                                                     'title' => be_instance_of(String),
                                                     'bunting' => be_in([true, false]),
                                                     'notes' => be_instance_of(String))
          end
        end
      end
    end
  end

  describe '::all_division_bank_holidays' do
    include_context 'when bank holidays data exists'

    after do
      described_class.instance_variable_set(
        :@config,
        described_class::Config.new(**described_class::DEFAULT_CONFIG_PARAMS)
      )
    end

    context 'when default division context == england-and-wales' do
      before { described_class.config { |c| c.default_division_context = 'england-and-wales' } }

      it do
        expect(described_class.all_division_bank_holidays)
          .to be_instance_of(Set)
          .and have_exactly(4).items
          .and all be_instance_of(described_class::BankHoliday)
      end
    end

    context 'when default division context == scotland' do
      before { described_class.config { |c| c.default_division_context = 'scotland' } }

      it do
        expect(described_class.all_division_bank_holidays)
          .to be_instance_of(Set)
          .and have_exactly(5).items
          .and all be_instance_of(described_class::BankHoliday)
      end
    end

    context 'when default division context == northern-ireland' do
      before { described_class.config { |c| c.default_division_context = 'northern-ireland' } }

      it do
        expect(described_class.all_division_bank_holidays)
          .to be_instance_of(Set)
          .and have_exactly(6).items
          .and all be_instance_of(described_class::BankHoliday)
      end
    end
  end

  describe '::for_division' do
    include_context 'when bank holidays data exists'

    after do
      described_class.instance_variable_set(
        :@config,
        described_class::Config.new(**described_class::DEFAULT_CONFIG_PARAMS)
      )
    end

    context 'when default_division_context == england-and-wales' do
      before { described_class.config { |c| c.default_division_context = 'england-and-wales' } }

      context 'when arg == scotland' do
        it { expect { |b| described_class.for_division('scotland', &b) }.to yield_with_no_args }

        context 'when yielding to expression checking scotland only bh' do
          it do
            expect(described_class.for_division('scotland') { Date.parse('2019-03-02').bank_holiday? }).to be true
          end
        end

        context 'when yielding to expression checking non-scotland bh' do
          it do
            expect(described_class.for_division('scotland') { Date.parse('2020-03-02').bank_holiday? }).to be false
          end
        end
      end
    end

    context 'when default_division_context == scotland' do
      before { described_class.config { |c| c.default_division_context = 'scotland' } }

      context 'when arg == northern-ireland' do
        it { expect { |b| described_class.for_division('northern-ireland', &b) }.to yield_with_no_args }

        context 'when yielding to expression checking northern-ireland only bh' do
          it do
            expect(described_class.for_division('northern-ireland') { Date.parse('2018-03-02').bank_holiday? })
              .to be true
          end
        end

        context 'when yielding to expression checking non-northern-ireland bh' do
          it do
            expect(described_class.for_division('northern-ireland') { Date.parse('2019-03-02').bank_holiday? })
              .to be false
          end
        end
      end
    end
  end

  describe '::using_data_source' do
    include_context 'when bank holidays data exists'

    after do
      described_class.instance_variable_set(
        :@config,
        described_class::Config.new(**described_class::DEFAULT_CONFIG_PARAMS)
      )
    end

    context 'when using a hash' do
      let(:data_source) do
        {
          'england-and-wales' => {
            'division' => 'england-and-wales',
            'events' => [
              { 'date' => '2021-01-01', 'title' => 'Ingurlaand' }
            ]
          },
          # Setting up here to assert symbolized keys are otay
          scotland: {
            division: :scotland,
            events: [
              { date: '2022-01-01'.to_date, title: 'Gr8 DaY' }
            ]
          }
        }
      end

      context 'when default_division_context == england-and-wales' do
        before { described_class.config { |c| c.default_division_context = 'england-and-wales' } }

        context 'when yielding to expression checking england-and-wales bh' do
          it do
            expect(described_class.using_data_source(-> { data_source }) { described_class.min })
              .to be_instance_of(described_class::BankHoliday).and have_attributes(title: 'Ingurlaand')
          end
        end
      end

      context 'when default_division_context == scotland' do
        before { described_class.config { |c| c.default_division_context = 'scotland' } }

        context 'when yielding to expression checking scotland bh' do
          it do
            expect(described_class.using_data_source(-> { data_source }) { described_class.min })
              .to be_instance_of(described_class::BankHoliday).and have_attributes(title: 'Gr8 DaY')
          end
        end
      end
    end
  end
end
