require_relative  'utils'

module SlackWormhole
  module Publish
    def self.start
      rtm.on :message do |data|
        case data.subtype
        when nil
          post_message(data)
        when 'bot_message'
        when 'file_share'
        when 'message_changed'
        when 'message_deleted'
        end
      end

      rtm.start!
    end

    def self.post_message(data)
      if user = user(data.user)
        username = user.profile.display_name ||
          user.profile.real_name ||
          user.name
        icon = user.profile.image_192
        channel_name = channel(data.channel).name

        payload = {
          action: "post",
          timestamp: data.ts,
          channel: channel_name,
          username: username,
          icon_url: icon,
          text: data.text,
          as_user: false,
        }

        publish(payload)
      end
    end

    def self.publish(payload)
      topic.publish(payload)
    end
  end
end
