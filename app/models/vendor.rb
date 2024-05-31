# frozen_string_literal: true

class Vendor < ApplicationRecord
  attr_accessor :legal_address

  has_many :users, dependent: :destroy
  has_many :addresses, dependent: :destroy
  accepts_nested_attributes_for :addresses

  has_one_attached :logotype
  has_many :vouchers, through: :users
  has_many :affiliations
  has_many :affiliates, through: :affiliations
  has_many :transactions, through: :vouchers

  validates_presence_of :name, :vat_id, :primary_email
  validates_uniqueness_of :name
  validates :vat_id, valvat: true

  before_validation :normalize_vat_id, if: :new_record?
  before_validation :set_legal_name, if: :vat_id_changed?
  after_save :create_or_update_system_user
  after_update :persist_legal_name, if: :saved_change_to_vat_id?

  def system_user
    User.system_user.where(vendor: self).first
  end

  def is_affiliated_with?(args)
    Affiliation.exists?(vendor_id: args[:vendor_id], affiliate_id: id)
  end

  def affiliated_vouchers
    affiliations.includes(vendor: :vouchers).flat_map { |aff| aff.vendor.vouchers.where(affiliate_network: true, active: true) }
  end

  def validate_vat
    transaction do
      valvat
      save
    end
  end

  def logotype_path
    if Rails.env.test?
      ActiveStorage::Blob.service.path_for(logotype.key)
    else
      ActiveStorage::Blob.service.url(logotype.key, expires_in: 1.hour, disposition: 'inline', filename: logotype.filename.to_s, content_type: 'image/png')
    end
  end

  private

  def create_or_update_system_user
    system_user = User.system_user.find_or_initialize_by(vendor: self)
    system_user.assign_attributes(email: primary_email, name: "#{name} (System User)", role: 'system_user')
    system_user.save(validate: false)
  end

  def normalize_vat_id
    self.vat_id = Valvat::Utils.normalize(vat_id)
  end

  def set_legal_name
    data = Valvat.new(vat_id).exists?(detail: true)
    self.legal_name = data[:name] if data
  end

  def persist_legal_name
    save if legal_name_changed?
  end
end
