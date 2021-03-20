# frozen_string_literal: true

RSpec.describe CustomCardGenerator do
  before do
    allow(SecureRandom).to receive(:alphanumeric).with(5).and_return('12345')
  end

  describe 'with a valid voucher' do
    describe 'of variant :servings' do
      context 'using design 1' do
        let!(:servings_voucher) { create(:servings_voucher, value: 10) }
        subject { described_class.new(servings_voucher, true, 1, :en) }
        let(:pdf) do
          file = File.open(subject.path)
          # binding.pry
          PDF::Inspector::Text.analyze_file(file)
        end

        it {
          is_expected.to be_an_instance_of CustomCardGenerator
        }

        it 'is expected to contain voucher data' do
          expect(pdf.strings)
            .to include('LUNCHCARD')
            .and include('Code: 12345')
            .and include('VALUE 10')
        end
      end

      context 'using design 2' do
        let!(:servings_voucher) { create(:servings_voucher, value: 10) }
        subject { described_class.new(servings_voucher, true, 2, :en) }
        let(:pdf) do
          file = File.open(subject.path)
          # binding.pry
          PDF::Inspector::Text.analyze_file(file)
        end

        it {
          is_expected.to be_an_instance_of CustomCardGenerator
        }

        it 'is expected to contain voucher data' do
          expect(pdf.strings)
            .to include('LUNCH')
            .and include('CARD')
            .and include('CODE: 12345')
            .and include('VALUE')
            .and include('10')
        end
      end
    end

    describe 'of variant :cash' do
      context 'using design 1' do
        let!(:cash_voucher) { create(:cash_voucher, value: 200) }
        subject { described_class.new(cash_voucher, true, 1, :en) }
        let(:pdf) do
          file = File.open(subject.path)
          PDF::Inspector::Text.analyze_file(file)
        end

        it {
          is_expected.to be_an_instance_of CustomCardGenerator
        }

        it 'is expected to contain voucher data' do
          expect(pdf.strings)
            .to include('GIFTCARD')
            .and include('Code: 12345')
            .and include('VALUE 200SEK')
        end
      end

      context 'using design 2' do
        let!(:cash_voucher) { create(:cash_voucher, value: 2) }
        subject { described_class.new(cash_voucher, true, 2, :en) }
        let(:pdf) do
          file = File.open(subject.path)
          PDF::Inspector::Text.analyze_file(file)
        end

        it {
          is_expected.to be_an_instance_of CustomCardGenerator
        }

        it 'is expected to contain voucher data' do
          expect(pdf.strings)
            .to include('GIFT')
            .and include('CARD')
            .and include('CODE: 12345')
            .and include('VALUE')
            .and include('200SEK')
        end
      end
    end
  end
end
