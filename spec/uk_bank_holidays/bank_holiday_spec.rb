# frozen_string_literal: true

RSpec.describe UKBankHolidays::BankHoliday do
  def init_bh(**params)
    division = params[:division] || UKBankHolidays::Division.new('england-and-wales')
    date = params[:date] || Date.today
    title = params[:title] || 'Great Bank Holiday'
    notes = params[:notes].presence
    bunting = params[:bunting].presence
    described_class.new(division:, date:, title:, notes:, bunting:)
  end

  describe '#initialize' do
    subject { described_class.new(**params) }

    let(:date) { Date.today }
    let(:division) { UKBankHolidays::Division.new('england-and-wales') }
    let(:title) { 'Mega Bank Holiday' }

    context 'when notes and bunting absent' do
      let(:params) { { date:, division:, title: } }

      it { is_expected.to be_instance_of(described_class).and have_attributes(notes: nil, bunting: false) }
    end

    context 'when notes and bunting present' do
      let(:params) { { date:, division:, title:, notes: 'Wow, notes', bunting: true } }

      it { is_expected.to be_instance_of(described_class).and have_attributes(notes: 'Wow, notes', bunting: true) }
    end
  end

  describe '#to_s' do
    let(:object) { init_bh(date:, title:) }

    context 'when 1st Jan 2025, title "New Year\'s Day"' do
      let(:date) { Date.new(2025, 1, 1) }
      let(:title) { "New Year's Day" }

      it { expect(object.to_s).to eq "Wed, 01 Jan 2025: New Year's Day" }
    end

    context 'when 20th July 2026, title "World Cup Win"' do
      let(:date) { Date.new(2026, 7, 20) }
      let(:title) { 'World Cup Win' }

      it { expect(object.to_s).to eq 'Mon, 20 Jul 2026: World Cup Win' }
    end
  end

  describe '#to_date' do
    let(:object) { init_bh(date:) }

    context 'when 1st Jan 2025' do
      let(:date) { Date.new(2025, 1, 1) }

      it { expect(object.to_date).to eq Date.new(2025, 1, 1) }
    end

    context 'when 20th July 2026' do
      let(:date) { Date.new(2026, 7, 20) }

      it { expect(object.to_date).to eq Date.new(2026, 7, 20) }
    end
  end

  describe '#next' do
    let(:date) { Date.today }
    let(:object) { init_bh(date:) }

    context 'when a subsequent BH exists' do
      let(:subsequent) { init_bh(date: object.to_date.next_month) }

      before { allow(date).to receive(:next_bank_holiday).and_return(subsequent) }

      it { expect(object.next).to eq subsequent }
    end

    context 'when a subsequent BH does not exist' do
      before { allow(date).to receive(:next_bank_holiday).and_return(nil) }

      it { expect(object.next).to be_nil }
    end
  end

  describe '#prev' do
    let(:date) { Date.today }
    let(:object) { init_bh(date:) }

    context 'when a previous BH exists' do
      let(:previous) { init_bh(date: object.to_date.last_month) }

      before { allow(date).to receive(:prev_bank_holiday).and_return(previous) }

      it { expect(object.prev).to eq previous }
    end

    context 'when a previous BH does not exist' do
      before { allow(date).to receive(:prev_bank_holiday).and_return(nil) }

      it { expect(object.prev).to be_nil }
    end
  end

  describe 'Comparable' do
    it { expect(described_class).to include(Comparable) }

    describe '#<=>' do
      let(:object) { init_bh(date: Date.tomorrow) }

      context 'when other is converted to date after subject\'s date' do
        let(:other) { (Date.today + 2.days).midday }

        it { expect(object <=> other).to be(-1) }
      end

      context 'when other is converted to date before subject\'s date' do
        let(:other) { Date.today }

        it { expect(object <=> other).to be(1) }
      end

      context 'when other is converted to date on subject\'s date' do
        let(:other) { Date.tomorrow.to_s }

        it { expect(object <=> other).to be(0) }
      end
    end
  end
end
