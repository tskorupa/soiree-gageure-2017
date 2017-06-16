# frozen_string_literal: true

class Ticket < ApplicationRecord
  STATES = %w(reserved authorized paid).freeze
  TICKET_TYPES = %w(meal_and_lottery lottery_only).freeze

  belongs_to :lottery
  belongs_to :seller, optional: true
  belongs_to :guest, optional: true
  belongs_to :sponsor, optional: true
  belongs_to :table, optional: true, counter_cache: true

  has_one :prize

  attr_readonly :lottery_id

  validates :ticket_type, inclusion: { in: TICKET_TYPES }
  validates(
    :number,
    numericality: { only_integer: true, greater_than: 0 },
    uniqueness: { scope: :lottery_id },
  )
  validates :state, inclusion: { in: STATES }
  validates(
    :drawn_position,
    numericality: { only_integer: true, greater_than: 0 },
    uniqueness: { scope: :lottery_id },
    allow_blank: true,
  )

  def can_be_registered?
    validate_ticket_is_not_registered
    validate_guest_is_present
    validate_table_is_required

    errors.none?
  end

  def register
    raise(ArgumentError, I18n.t('ticket_registrations.errors.already_registered')) if registered?
    update!(registered: true)
  end

  private

  def validate_ticket_is_not_registered
    return unless registered?

    errors.add(:base, I18n.t('ticket_registrations.errors.already_registered'))
  end

  def validate_guest_is_present
    return if guest

    errors.add(
      :guest,
      :blank,
      message: I18n.t('ticket_registrations.errors.ticket.guest'),
    )
  end

  def validate_table_is_required
    return unless ticket_type == 'meal_and_lottery'
    return if table

    errors.add(:base, I18n.t('ticket_registrations.errors.table_number'))
  end
end
