# frozen_string_literal: true

class TransactionsController < ApplicationController
  before_action :find_voucher
  before_action :check_requested_amount
  def create
    transaction = @voucher.transactions.create(
      date: DateTime.now,
      amount: params[:value] ? params[:value].to_i : 1,
      honored_by: params[:honored_by] && params[:honored_by]
    )
    points = params[:value] || 1
    PassKitService.consume(@voucher.code, points) if @voucher.pass_kit_id?
    if transaction.persisted?
      @voucher.reload
      render json: {
        message: I18n.t('voucher.transaction_added', code: @voucher.code),
        voucher: Vouchers::ShowSerializer.new(@voucher)
      }, status: 201
    else
      render json: { message: transaction.errors.full_messages.to_sentence }, status: 422
    end
  end

  private

  def check_requested_amount
    if @voucher.current_value - params[:value].to_i < 0
      render json: { message: I18n.t('voucher.limit_exceeded_message'), voucher: Vouchers::ShowSerializer.new(@voucher) },
             status: 422
    end
  end

  def find_voucher
    @voucher = Voucher.find(params[:voucher_id])
  end
end
