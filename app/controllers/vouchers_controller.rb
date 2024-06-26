# frozen_string_literal: true

class VouchersController < ApplicationController
  include ValueValidations

  before_action :authenticate_user!, only: %i[create]
  before_action :find_voucher, only: %i[show update]
  before_action :validate_servings_value, if: proc {
                                                voucher_params[:value] && voucher_params[:variant] == 'servings'
                                              }, only: :create
  before_action :validate_cash_value, if: proc { voucher_params[:variant] == 'cash' }, only: :create
  after_action :distribute, only: %i[update]
  rescue_from ActiveRecord::RecordNotFound, with: :voucher_not_found

  def index
    if current_user.admin?
      vouchers = Voucher.all
    else
      vendor_vouchers = current_user.vendor.vouchers
      affiliated_vouchers = current_user.vendor.affiliated_vouchers
      vouchers = vendor_vouchers + affiliated_vouchers
    end
  
    if vouchers.any?
      render json: vouchers, each_serializer: Vouchers::ShowSerializer
    else
      render json: { vouchers: [] }
    end
  end

  def show
    render json: @voucher, serializer: Vouchers::ShowSerializer if @voucher
  end

  def create
    # we need to validate current_user is a vendor
    if params[:command] == 'batch'
      amount = params[:amount].to_i
      amount.times { Voucher.create(voucher_params.merge(issuer: current_user)) }
      render json: { message: I18n.t('voucher.n_created', count: amount) }, status: 201
    else
      voucher = Voucher.create(voucher_params.merge(issuer: current_user))
      if voucher.persisted?
        render json: { message: I18n.t('voucher.created') }, status: 201
      else
        render json: { message: voucher.errors.full_messages.to_sentence }, status: 422
      end
    end
  end

  def update
    if voucher_params[:command] == 'activate' && @voucher.activate!
      render json: { message: I18n.t('voucher.activated') }, status: 201
    else
      render json: { message: @voucher.errors.full_messages.to_sentence }, status: 422
    end
  end

  def generate_card
    voucher = Voucher.find(params[:voucher_id])
    if voucher.generate_pdf_card
      render json: { message: I18n.t('voucher.card_generated'), url: voucher.pdf_card_path }, status: :created
    end
  end

  private

  def find_voucher
    @voucher = Voucher.find_by!(code: params[:id])
  end

  def distribute
    Async do |action|
      action.async do
        set_owner
        set_pass_kit
        create_pdf
        send_activation_email
      end
    end
  end

  def set_owner
    if params[:voucher][:email] && @voucher.owner.nil?
      user = User.find_by_email(params[:voucher][:email])
      associated_user = user || nil
      Owner.find_or_create_by(
        email: params[:voucher][:email],
        voucher: @voucher,
        user: associated_user
      )
    end
  end

  def set_pass_kit
    if params[:voucher][:activate_wallet] && !@voucher.pass_kit_id?
      pass_kit = PassKitService.enroll(@voucher.code, @voucher.value, @voucher.vendor.name).symbolize_keys
      @voucher.update(pass_kit_id: pass_kit[:id])
    end
  end

  def create_pdf
    if params[:voucher][:activate_pdf]
      options = params[:voucher][:pdf_options].permit!.to_h.symbolize_keys
      @voucher.generate_pdf_card(options)
    end
  end

  def send_activation_email
    (@voucher.owner && @voucher.owner.email) && VoucherDistributionMailer.activation(@voucher).deliver
  end

  def voucher_params
    params.require(:voucher).permit(:value, :command, :owner, :variant, :affiliate_network)
  end

  def voucher_not_found
    render json: { message: I18n.t('voucher.not_found_message') }, status: 404
  end
end
