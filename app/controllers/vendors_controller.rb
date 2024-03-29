# frozen_string_literal: true

# This controller needs to be revisited.
# Way to many things happening here.
class VendorsController < ApplicationController
  after_action :attach_logotype, only: %i[create update]
  rescue_from ActiveModel::ValidationError, with: :render_error_message
  def create
    @vendor = current_user && !current_user.admin? ? current_user.create_vendor(vendor_params.merge(users: [current_user])) : Vendor.create(vendor_params)
    params[:user] ? user_create(@vendor) : current_user.update(vendor: @vendor)
    if @vendor.persisted?
      @vendor.reload
      render json: @vendor, serializer: Vendors::ShowSerializer, status: 201
    else
      raise ActiveModel::ValidationError, vendor
    end
  end

  def show
    vendor = Vendor.find(params[:id])
    render json: vendor, serializer: Vendors::ShowSerializer
  end

  def update
    @vendor = Vendor.find(params[:id])
    @vendor.update(vendor_params)
    render json: @vendor, serializer: Vendors::ShowSerializer
  end

  private

  def vendor_params
    params.require(:vendor)
          .permit(
            :name,
            :description,
            :primary_email,
            :vat_id,
            addresses_attributes: %i[street post_code city country]
          )
  end

  def user_params
    if params[:user]
      params.require(:user)
            .permit(:name, :email, :password, :password_confirmation)
    end
  end

  def attach_logotype
    DecodeService.attach_image(params[:vendor][:logotype], @vendor, 'logotype') if params[:vendor][:logotype]
  end

  def user_create(vendor)
    user = User.find_or_create_by(email: user_params[:email]) do |instance|
      instance.update(user_params)
    end
    user.vendor = vendor
    user.save
    raise ActiveModel::ValidationError, user if user.invalid?
  end

  def render_error_message(exception)
    render json: { message: exception.model.errors.full_messages.to_sentence }, status: 422
  end
end
