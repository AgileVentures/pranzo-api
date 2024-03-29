# frozen_string_literal: true

require_relative './credentials'

RSpec.describe 'POST /api/vendors/:vendor_id/reports', type: :request do
  include_context 'credentials'
  let!(:servings_voucher) { create(:servings_voucher, value: 15, issuer: vendor_user) }
  let!(:servings_voucher_2) { create(:servings_voucher, value: 15, issuer: vendor_user) }
  let!(:servings_voucher_3) { create(:servings_voucher, value: 15, issuer: vendor_user) }
  let!(:cash_voucher) { create(:cash_voucher, value: 1000, issuer: vendor_user) }
  describe ':this_month' do
    let!(:transactions) do
      Timecop.freeze(1.week.ago.beginning_of_week)
      create(:transaction, voucher: servings_voucher_3)
      create(:transaction, voucher: cash_voucher, amount: 100)
      create(:transaction, voucher: cash_voucher, amount: 150)
      Timecop.return
      Timecop.freeze(1.week.ago.beginning_of_week + 1.day)
      create(:transaction, voucher: servings_voucher_2)
      Timecop.return
      Timecop.freeze(1.week.ago.beginning_of_week + 3.day)
      create(:transaction, voucher: servings_voucher_2)
      Timecop.return
      Timecop.freeze(1.week.ago.beginning_of_week + 5.day)
      create(:transaction, voucher: servings_voucher_2)
      create(:transaction, voucher: cash_voucher, amount: 100)
      Timecop.return
      Timecop.freeze(3.day.ago)
      create(:transaction, voucher: servings_voucher_3)
      create(:transaction, voucher: servings_voucher_2)
      create(:transaction, voucher: servings_voucher)
      create(:transaction, voucher: servings_voucher_2)
      create(:transaction, voucher: servings_voucher)
      Timecop.return
      Timecop.freeze(2.day.ago)
      create(:transaction, voucher: servings_voucher_3)
      create(:transaction, voucher: servings_voucher_2)
      create(:transaction, voucher: servings_voucher)
      create(:transaction, voucher: servings_voucher_2)
      create(:transaction, voucher: servings_voucher)
      Timecop.return
      Timecop.freeze(1.day.ago)
      create(:transaction, voucher: servings_voucher_3)
      create(:transaction, voucher: servings_voucher_2)
      create(:transaction, voucher: servings_voucher_2)
      create(:transaction, voucher: servings_voucher_2)
      create(:transaction, voucher: servings_voucher_3)
      create(:transaction, voucher: servings_voucher)
      create(:transaction, voucher: servings_voucher_2)
      create(:transaction, voucher: cash_voucher, amount: 75)
      Timecop.return
      create(:transaction, voucher: servings_voucher_3)
      create(:transaction, voucher: servings_voucher)
      create(:transaction, voucher: cash_voucher, amount: 50)
    end
    before do
      post "/api/vendors/#{vendor.id}/reports", params: { period: 'this_month', command: 'preview' },
                                                headers: valid_auth_headers_for_vendor_user
    end
    subject { response }

    it { is_expected.to have_http_status 201 }
  end

  describe ':last_month' do
    let!(:transactions) do
      1.month.ago.beginning_of_month.to_date.upto((1.month.ago.beginning_of_month + 14.days).to_date).each do |date|
        Timecop.freeze(date)
        create(:transaction, voucher: servings_voucher_3)
        create(:transaction, voucher: cash_voucher, amount: 10)
      end
      Timecop.return
      (1.month.ago.beginning_of_month.to_date + 15.days).to_date.upto((1.month.ago.beginning_of_month + 31.days).to_date).each do |date|
        Timecop.freeze(date)
        create(:transaction, voucher: [servings_voucher_2, servings_voucher].sample)
        create(:transaction, voucher: cash_voucher, amount: 1)
      end
      Timecop.return
    end

    before do
      post "/api/vendors/#{vendor.id}/reports", params: { period: 'last_month', command: 'preview' },
                                                headers: valid_auth_headers_for_vendor_user
    end
    subject { response }

    it { is_expected.to have_http_status 201 }

    it 'is expected to include a base64 encoded pdf' do
      expect(response_json).to have_key 'report_as_base64'
    end
  end

  describe ':today' do
    before do
      create(:transaction, voucher: servings_voucher_3)
      create(:transaction, voucher: cash_voucher, amount: 75)
      post "/api/vendors/#{vendor.id}/reports", params: { period: 'today', command: 'preview' },
                                                headers: valid_auth_headers_for_vendor_user
    end
    subject { response }

    it { is_expected.to have_http_status 201 }

    it 'is expected to include a base64 encoded pdf' do
      expect(response_json).to have_key 'report_as_base64'
    end
  end

  describe ':no transactions' do
    describe '::preview' do
      before do
        post "/api/vendors/#{vendor.id}/reports", params: { period: 'today', command: 'preview' },
                                                  headers: valid_auth_headers_for_vendor_user
      end
      subject { response }

      it { is_expected.to have_http_status 201 }

      it 'is expected to include a base64 encoded pdf' do
        expect(response_json).to have_key 'report_as_base64'
      end
    end

    describe '::deliver' do
      before do
        post "/api/vendors/#{vendor.id}/reports", params: { period: 'today', command: 'deliver' },
                                                  headers: valid_auth_headers_for_vendor_user
      end
      subject { response }

      it { is_expected.to have_http_status 201 }

      it 'is expected NOT to include a base64 encoded pdf' do
        expect(response_json).not_to have_key 'report_as_base64'
      end

      it 'is expected to send email' do
        expect(email_queue).to eq 1
      end

      it 'is expected to iclude pdf attachmant' do
        expect(email.attachments.count).to eq 1
      end

      it 'is expected to iclude link to passkit' do
        expect(email_html_part).to include 'Här är din rapport'
      end
    end
  end
end
