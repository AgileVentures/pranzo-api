# frozen_string_literal: true

RSpec.describe Vendor, type: :model do
  describe 'Database table' do
    it {
      is_expected.to have_db_column(:name)
        .of_type(:string)
    }
    it {
      is_expected.to have_db_column(:primary_email)
        .of_type(:string)
    }
  end
  describe 'Factory' do
    it {
      expect(create(:vendor)).to be_valid
    }
  end

  describe 'Associations' do
    # xit { is_expected.to have_and_belong_to_many :categories }
    it { is_expected.to have_many :addresses }
    it { is_expected.to have_many :users }
  end

  describe '#logotype' do
    subject { create(:vendor).logotype }

    it {
      is_expected.to be_an_instance_of ActiveStorage::Attached::One
    }
  end

  describe '#system_user' do
    let(:vendor) { create(:vendor, primary_email: 'my_primary@mail.com') }
    subject { vendor.system_user }
    it 'has the email of vendor' do
      expect(subject.email).to eq vendor.primary_email
    end
  end
end