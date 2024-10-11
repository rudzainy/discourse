# frozen_string_literal: true

module Chat
  class DirectMessageChannel < Channel
    alias_method :direct_message, :chatable

    def direct_message_channel?
      true
    end

    def allowed_user_ids
      direct_message.user_ids
    end

    def read_restricted?
      true
    end

    def title(user)
      direct_message.chat_channel_title_for_user(self, user)
    end

    def generate_auto_slug
      self.slug.blank?
    end

    def leave(user)
      return remove(user) unless direct_message&.group
      transaction do
        membership_for(user)&.destroy!
        direct_message.direct_message_users.where(user: user).destroy_all
      end
    end
  end
end
