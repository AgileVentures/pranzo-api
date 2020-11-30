# frozen_string_literal: true

RSpec.describe Voucher, type: :model do
  describe 'Database table' do
    it {
      is_expected.to have_db_column(:value)
        .of_type(:integer)
    }
    it {
      is_expected.to have_db_column(:active)
        .of_type(:boolean)
    }
  end

  describe 'Factory' do
    it {
      expect(create(:voucher)).to be_valid
    }
  end

  describe 'attributes' do
    it { is_expected.to have_readonly_attribute(:code) }
  end

  describe 'associations' do
    it {
      is_expected.to have_many(:transactions)
        .dependent(:destroy)
    }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :value }

    describe ':transactions count for voucher with value 10' do
      subject { create(:voucher, value: 10) }
      let!(:transactions) do
        9.times do
          create(:transaction, voucher: subject)
        end
      end

      context 'on creating 10th transaction' do
        it 'is expected to be valid' do
          transaction = subject.transactions.new(attributes_for(:transaction))
          expect(transaction.save).to eq true
        end
      end

      context 'on creating 11th transaction' do
        let!(:last_valid_transaction) { create(:transaction, voucher: subject) }
        let(:transaction) { subject.transactions.new(attributes_for(:transaction)) }
        it 'is expected to be invalid' do
          expect(transaction.save).to eq false
        end

        it 'is expected to add error message to transaction' do
          transaction.save
          expect(
            transaction.errors.full_messages
          ).to include 'Voucher limit exceeded'
        end

        it 'is expected to add error message to voucher' do
          transaction.save
          expect(
            subject.errors.full_messages
          ).to include 'Voucher value limit exceeded'
        end
      end
    end

    describe ':transactions count for voucher with value 15' do
      subject { create(:voucher, value: 15) }
      let!(:transactions) do
        14.times do
          create(:transaction, voucher: subject)
        end
      end

      context 'on creating 15th transaction' do
        it 'is expected to be valid' do
          transaction = subject.transactions.new(attributes_for(:transaction))
          expect(transaction.save).to eq true
        end
      end

      context 'on creating 16th transaction' do
        let!(:last_valid_transaction) { create(:transaction, voucher: subject) }
        let(:transaction) { subject.transactions.new(attributes_for(:transaction)) }
        it 'is expected to be invalid' do
          expect(transaction.save).to eq false
        end

        it 'is expected to add error message to transaction' do
          transaction.save
          expect(
            transaction.errors.full_messages
          ).to include 'Voucher limit exceeded'
        end

        it 'is expected to add error message to voucher' do
          transaction.save
          expect(
            subject.errors.full_messages
          ).to include 'Voucher value limit exceeded'
        end
      end
    end
  end

  describe '#qr attributes' do
    let(:voucher) { create(:voucher) }
    describe 'white qr code transparent background (qr_white)' do
      subject { voucher.qr_white }

      it { is_expected.to be_attached }
      it { is_expected.to be_an_instance_of ActiveStorage::Attached::One }
    end

    describe 'black qr code transparent background (qr_dark)' do
      subject { voucher.qr_dark }

      it { is_expected.to be_attached }
      it { is_expected.to be_an_instance_of ActiveStorage::Attached::One }
    end
  end

  describe '#activate!' do
    subject { create(:voucher) }
    it do
      expect{
        subject.activate!
      }.to change{subject.active}.from(false).to(true)
    end
  end
end
