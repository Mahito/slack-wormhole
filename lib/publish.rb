require_relative  'utils'

module SlackWormhole
  module Publish
    def self.start
      rtm.on :message do |data|
        case data.subtype
        when nil
          if data.files
            post_files(data)
          else
            post_message(data)
          end
        when 'bot_message'
        when 'message_changed'
          edit_message(data)
        when 'message_deleted'
          delete_message(data)
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
          action: 'post',
          timestamp: data.ts,
          room: channel_name,
          username: username,
          icon_url: icon,
          text: data.text,
        }

        publish(payload)
      end
    end

    def self.post_files(data)
        payload = {
          channel: data.channel,
          text: 'ファイル転送はまだてきてません。PR待ってます☆ミ',
          as_user: false
        }
      web.chat_postMessage(payload)
    end

    def self.edit_message(data)
      if user = user(data.message.user)
        payload = {
          action: 'update',
          timestamp: data.message.ts,
          text: data.message.text,
        }

        publish(payload)
      end
    end

    def self.delete_message(data)
      payload = {
        action: 'delete',
        timestamp: data.deleted_ts,
      }

      publish(payload)
    end

    def self.publish(payload)
      topic.publish(payload)
    end
  end
end
