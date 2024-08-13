# Copyright (C) 2012-2024 Zammad Foundation, https://zammad-foundation.org/

class Checklist < ApplicationModel
  include HasDefaultModelUserRelations
  include ChecksClientNotification
  include HasHistory
  include Checklist::TriggersSubscriptions
  include Checklist::Assets
  include CanChecklistSortedItems

  after_create :ensure_at_least_one_item

  belongs_to :ticket, optional: true
  has_many :items, inverse_of: :checklist, dependent: :destroy

  scope :for_user, ->(user) { joins(:ticket).where(ticket: { group: user.group_ids_access('read') }) }

  validates :name,      presence: { allow_blank: true }
  validates :ticket_id, presence: true, uniqueness: { allow_nil: true }

  history_attributes_ignored :sorted_item_ids

  def history_log_attributes
    {
      related_o_id:           ticket_id,
      related_history_object: 'Ticket',
    }
  end

  def history_create
    history_log('created', created_by_id, { value_to: name })
  end

  def history_destroy
    history_log('removed', updated_by_id, { value_to: name })
  end

  def notify_clients_data_attributes
    {
      id:            id,
      ticket_id:     ticket_id,
      updated_at:    updated_at,
      updated_by_id: updated_by_id,
    }
  end

  def completed?
    !items.exists?(checked: false)
  end

  private

  def ensure_at_least_one_item
    return if items.any?

    items.create!(text: '', created_by: created_by, updated_by: updated_by)
  end
end
