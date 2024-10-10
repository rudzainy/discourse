# frozen_string_literal: true

class Flags::ToggleFlag
  include Service::Base

  contract do
    attribute :flag_id, :integer

    validates :flag_id, presence: true
  end
  model :flag
  policy :invalid_access
  transaction do
    step :toggle
    step :log
  end

  private

  def fetch_flag(contract:)
    Flag.find_by(id: contract.flag_id)
  end

  def invalid_access(guardian:)
    guardian.can_toggle_flag?
  end

  def toggle(flag:)
    flag.update!(enabled: !flag.enabled)
  end

  def log(guardian:, flag:)
    StaffActionLogger.new(guardian.user).log_custom(
      "toggle_flag",
      { flag: flag.name, enabled: flag.enabled },
    )
  end
end
